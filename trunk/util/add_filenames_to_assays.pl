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

use Getopt::Long;
use Pod::Usage;
use XML::LibXML;

use ClinStudy::XML::Builder;

use Data::Dumper;

sub parse_args {

    my ( $xmlfile, $xsd, $want_help );

    GetOptions(
        "x|xml=s"    => \$xmlfile,
        "d|schema=s" => \$xsd,        
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    my @files = @ARGV;

    unless ( $xmlfile && $xsd && @files ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $parser = XML::LibXML->new();
    my $xml    = $parser->parse_file($xmlfile);

    return( $xml, $xsd, \@files );
}

my ( $xml, $xsd, $files ) = parse_args();

my $builder = ClinStudy::XML::Builder->new(
    schema_file => $xsd,
    document    => $xml,
    root        => $xml->getDocumentElement(),
);

unless ( $builder->validate() ) {
    die("Error: Input XML not valid!\n");
}

# We look at the assays with the longest identifiers first.
my @assays = $xml->findnodes('//Assay');
my @sorted = reverse map { $_->[1] }
    sort { $a->[0] <=> $b->[0] }
    map { [ length($_->getAttribute('identifier')), $_ ] } @assays;
my @files = @$files;

# This is the business end.
ASSAY:
foreach my $assay ( @sorted ) {
    if ( my $id = $assay->getAttribute('identifier') ) {
        for ( my $n = 0; $n < @files; $n++ ) {
            if ( $files[$n] =~ /$id/ ) {
                $assay->setAttribute('filename', $files[$n]);

                # Remove each matched file so we don't get duplicates.
                splice( @files, $n, 1 );
            }
        }
    }
    else {
        next ASSAY;
    }
}

# Output.
$builder->dump();

__END__

=head1 NAME

add_filenames_to_assays.pl

=head1 SYNOPSIS

 add_filenames_to_assays.pl -x <ClinStudyML file> -d <XML Schema file> <list of filenames>

=head1 DESCRIPTION

Script which takes a pre-existing list of Assays in ClinStudyML
format, and a list of filenames, and attempts to match up filenames
with the Assay identifier. Obviously this can backfire quite
considerably, so the output should be checked to make sure it's as
expected. It's worth stripping out Assays with inappropriate
identifiers before running the script. This is a fairly simple script,
nothing clever to see here.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
