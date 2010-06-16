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

package ClinStudy::MAGETAB::Dumper;

use 5.008;

use strict; 
use warnings;

use Moose;

use Bio::MAGETAB;
use Bio::MAGETAB::Util::Builder;
use Bio::MAGETAB::Util::Writer;
use URI;
use LWP::UserAgent;
use XML::LibXML;

use Carp;
use Data::Dumper;

our $VERSION = '0.01';

has 'uri'      => ( is       => 'ro',
                    isa      => 'URI',
                    required => 1, );

has 'username' => ( is       => 'ro',
                    isa      => 'Str',
                    required => 1, );

has 'password' => ( is       => 'ro',
                    isa      => 'Str',
                    required => 1, );

has 'builder'  => ( is       => 'ro',
                    isa      => 'Bio::MAGETAB::Util::Builder',
                    required => 1,
                    default  => sub { Bio::MAGETAB::Util::Builder->new() }, );

sub dump {

    my ( $self ) = @_;

    # FIXME whence $sdrf_file?
    my $sdrf_file = 'testing.sdrf';

    # Sort objects into SDRFRows.
    my $sdrf = $self->builder->find_or_create_sdrf({
        uri => $sdrf_file,
    });
    $sdrf->add_nodes( [ $self->builder->get_magetab()->get_nodes() ] );

    # Write out all objects.
    my $writer = Bio::MAGETAB::Util::Writer->new(
        magetab => $self->builder->get_magetab(),
    );

    $writer->write();

    return;
}

sub _query_rest {

    my ( $self, $querytype, $querystr ) = @_;

    my $uri = $self->uri();

    # Strip trailing /, add the path to the REST API for query type
    # (typically 'assay_file').
    $uri =~ s/\/+$//;
    $uri .= sprintf("/rest/%s/%s", $querytype, $querystr);
    my $ua = LWP::UserAgent->new();

    # Add our login details and content type.
    $ua->default_header( 'X-Username' => $self->username() );
    $ua->default_header( 'X-Password' => $self->password() );
    $ua->default_header( 'Content-Type' => 'text/xml' );

    # Get the response.
    my $res = $ua->get($uri);

    # Error-check the response, give feedback on failure.
    unless ( $res->is_success() ) {
        warn(sprintf("Warning: ClinWebQuery returned error %s for %s %s\n",
                     $res->status_line, $querytype, $querystr));
        return;
    }

    # Parse the returned data, remove the unnecessary top-level wrappers.
    my $doc     = XML::LibXML->load_xml(string => $res->content);
    my $dataset = $doc->find('/opt/data');
    if ( $dataset->size() != 1 ) {
        croak("Error: ClinStudyWeb REST response must contain a single data entry");
    }
    my $data = $dataset->get_node(0);

    return $data;
}

sub _create_datafile {

    my ( $self, $filename ) = @_;

    # FIXME this should be a config setting.
    my %extmap = (
        'cel' => 'Affymetrix CEL',
        'chp' => 'Affymetrix CHP',
        'txt' => 'Unknown Text',
        'gpr' => 'GeneSpring',
    );

    my $dformat_str;
    my ( $filext ) = ( $filename =~ /\. \w{3,5} \z/ixms );
    if ( $filext ) {
        unless ( $dformat_str = $extmap{ lc( $filext ) } ) {
            $dformat_str = 'Unknown';
        }
    }
    else {
        $dformat_str = 'Unknown';
    }

    my $builder = $self->builder();

    my $dtype = $builder->find_or_create_controlled_term({
        category => 'DataType',
        value    => 'raw',
    });

    my $dformat = $builder->find_or_create_controlled_term({
        category => 'DataFormat',
        value    => $dformat_str,
    });

    # Data file
    my $file = $builder->find_or_create_data_file({
        uri        => $filename,
        dataType   => $dtype,
        format     => $dformat,
    });

    return $file;
}

sub add_file {

    my ( $self, $filename ) = @_;

    my $xmldata = $self->_query_rest( 'assay_file', $filename );

    my $builder = $self->builder();

    # Data file
    my $file = $self->_create_datafile( $filename );

    # Hybridization
    my $ttype = $builder->find_or_create_controlled_term({
        category => 'TechnologyType',
        value    => 'hybridization',
    });

    my $hybid = $xmldata->getAttribute('identifier');
    my $hyb = $builder->find_or_create_assay({
        name           => $hybid,
        technologyType => $ttype,
    });
    $builder->find_or_create_edge({
        inputNode  => $hyb,
        outputNode => $file,
    });

    foreach my $channel ( $xmldata->findnodes('./channels') ) {
        my $label_str = $channel->getAttribute('label');
        my $label     = $builder->find_or_create_controlled_term({
            category => 'LabelCompound',
            value    => $label_str,
        });

        foreach my $sample ( $channel->findnodes('./sample' ) ) {
            my $sample_name = $sample->getAttribute('sample_name');
            my $le = $builder->find_or_create_labeled_extract({
                name  => "$sample_name ($label_str)",
                label => $label,
            });
            my $ex = $builder->find_or_create_extract({
                name  => $sample_name,
            });
            my $sa = $builder->find_or_create_sample({
                name  => $sample_name,
            });
            my $so = $builder->find_or_create_source({
                name  => $sample->getAttribute('patient_number'),
            });

            # Create the edges also.
            $builder->find_or_create_edge({
                inputNode  => $so,
                outputNode => $sa,
            });
            $builder->find_or_create_edge({
                inputNode  => $sa,
                outputNode => $ex,
            });
            $builder->find_or_create_edge({
                inputNode  => $ex,
                outputNode => $le,
            });
            $builder->find_or_create_edge({
                inputNode  => $le,
                outputNode => $hyb,
            });
        }
    }

    return;
}

1;
__END__

=head1 NAME

ClinStudy::MAGETAB::Dumper - MAGE-TAB export from the ClinStudy database.

=head1 SYNOPSIS

 use ClinStudy::MAGETAB::Dumper;
 my $dumper = ClinStudy::MAGETAB::Dumper->new(
     uri => $database_home_uri,
 );

 # Add annotation for each of the files being included.
 foreach my $file ( @filenames ) {
    $dumper->add_file( $file );
 }

 # Write out the MAGE-TAB files.
 $dumper->dump();

=head1 DESCRIPTION

Module created to facilitate the export of MAGE-TAB documents from the
ClinStudy database, primarily using the web-based REST API.

=head2 OPTIONS

=over 2

=item uri

The main URI of the ClinStudy web application (for example, when
running under the Catalyst test server this would be
http://localhost:3000 by default).

=item username

The username to use in connecting to the database.

=item password

The password to use in connecting to the database.

=item builder

A Bio::MAGETAB::Util::Builder object. This will be created automatically by
default; this option should not typically be used unless you know what
you're doing.

=back

=head1 SEE ALSO

L<Bio::MAGETAB>, L<ClinStudy::XML::Dumper>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

