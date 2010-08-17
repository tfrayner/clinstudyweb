#!/usr/bin/env perl
#
# Copyright 2010 Tim Rayner, University of Cambridge
# 
# This file is part of ClinStudy::Web.
# 
# ClinStudy::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# ClinStudy::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

use strict;
use warnings;

use Spreadsheet::ParseExcel;
use XML::LibXML;
use CIMR::SheetIterator;
use CIMR::Parser::ARR;

my %ARRFILE_MAP;

sub rewrite_arr {

    my ( $arraydata, $userdata ) = @_;

    my $arrayname = $arraydata->{'Array Name'};
    my $arrfile   = $ARRFILE_MAP{$arrayname};
    unless ( $arrfile ) {
        warn("Warning: No ARR file found for $arrayname. Skipping.\n");
        return;
    }

    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($arrfile);

    # Some ARR files don't even have a UA group element; fix that here.
    my @parentnodes = $doc->findnodes('/ArraySetFile/UserAttributes');
    unless ( scalar @parentnodes ) {
        my $ua = $doc->createElement('UserAttributes');
        $doc->getDocumentElement()->addChild($ua);
    }
    
    my $refnode;
    ITEM:
    foreach my $item ( @$userdata ) {
        my @nodes = $doc->findnodes('/ArraySetFile/UserAttributes/UserAttribute');
        foreach my $node ( @nodes ) {
            my $name = $node->findvalue('@Name');
            if ( $name eq $item->{'key'}{'Name'} ) {

                $refnode = $node;

                # We only bail as late as here so that the $refnode is correctly set.
                next ITEM unless ( defined $item->{'value'} && $item->{'value'} ne q{} );

                my ( $userattr ) = $node->findnodes('./UserAttributeValue/text()');
                unless ( $userattr ) {
                    my $elem  = $doc->createElement('UserAttributeValue');
                    $userattr = $doc->createTextNode($item->{'value'});
                    $node->addChild($elem);
                    $elem->addChild($userattr);
                }
                else {
                    $userattr->setData($item->{'value'});
                }
                next ITEM;
            }
        }

        # Not found; create a new node.
        my ( $userattr_container ) = $doc->findnodes('/ArraySetFile/UserAttributes');
        my $userattr = $doc->createElement('UserAttribute');

        if ( $refnode ) {

            # Add node after the previous hit.
            $userattr_container->insertAfter($userattr, $refnode);
        }
        else {

            # Add to the start of the node list.
            $userattr_container->insertBefore($userattr, $userattr_container->firstChild);
        }

        # Set the node attributes (arbitrary order).
        while ( my ( $attr, $val ) = each %{$item->{'key'}} ) {
            $userattr->setAttribute( $attr, $val );
        }
        my $attrvalue = $doc->createElement('UserAttributeValue');
        my $text      = $doc->createTextNode($item->{'value'});
        $attrvalue->addChild($text);
        $userattr->addChild($attrvalue);

        $refnode = $userattr;
    }

    open ( my $fh, '>', "$arrfile.fixed" )
        or die("Error: Unable to open output file: $!");
    print $fh $doc->toString;
}

my @spreadsheets = @ARGV;

unless ( scalar @spreadsheets ) {
    die("Usage: $0 <list of IMS spreadsheets>\n");
}

# Populate %ARRFILE_MAP so we know which ARR file corresponds to a
# given Array Name
opendir( my $dir, '.' )
    or die("Unable to open working directory for reading: $!");
my @files = grep { /\.ARR$/i } readdir($dir);
foreach my $file ( @files ) {
    my $parser = CIMR::Parser::ARR->new(arr_file => $file);
    if ( exists $ARRFILE_MAP{ $parser->array_name() } ) {
        die("Error: Multiple ARR files referring to the same array name (latest is $file).\n");
    }
    else {
        $ARRFILE_MAP{ $parser->array_name() } = $file;
    }
}
closedir( $dir );
unless ( scalar grep { defined $_ } values %ARRFILE_MAP ) {
    die("Error: No ARR files found in current working directory.");
}

# Read the spreadsheets.
foreach my $file ( @spreadsheets ) {

    my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);

    my $sheet = $excel->{Worksheet}->[0]
        or die("No worksheet at position zero!");

    my $iter = CIMR::SheetIterator->new(sheet => $sheet);
    my $header = $iter->header();

    ROW:
    while ( my $row = $iter->next() ) {

        next ROW unless $row->{'Array Name'};

        unless ( $row->{'Sample File Name'} eq $row->{'Array Name'} ) {
            die("Error: Sample File Name and Array Name do not match in file $file.");
        }

        my ( @userdata, %arraydata );
        for ( my $i = 0; $i < @$header; $i++ ) {
            my $key = $header->[$i];
            my $value = $row->{$key};

            # Not interested in Excel's foibles.
            $value = q{} if ( $value eq '#DIV/0!' );
            if ( $key =~ m/:triad:/ ) {
                my ( $name, $namespace, $type, $required ) = split /:/, $key;
                push @userdata, {
                    key => {
                        Name      => $name,
                        Type      => $type,
                        Required  => ( $required && $required =~ /Required/i ) ? 'true' : 'false',
                        Namespace => $namespace,
                    },
                    value => $value,                        
                }
            }
            else {
                $arraydata{ $key } = $value;
            }
        }

        # Rewrite the ARR file.
        rewrite_arr( \%arraydata, \@userdata );
    }
}
