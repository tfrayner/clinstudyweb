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
use ClinStudy::Web;
use URI;
use LWP::UserAgent;
use XML::LibXML;
use List::Util qw(first);
use Storable qw(dclone);
use Config::YAML;
use Readonly;

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

has 'config_file' => ( is       => 'ro',
                       isa      => 'Str',
                       required => 1, );

has '_config'  => ( is       => 'rw',
                    isa      => 'HashRef',
                    required => 0 );

has '_investigation' => ( is       => 'rw',
                          isa      => 'Bio::MAGETAB::Investigation',
                          required => 0 );

Readonly my $HYB_PROTOCOL_NAME         => 'Hybridization';
Readonly my $LABELING_PROTOCOL_NAME    => 'Labeling';
Readonly my $EXTRACTION_PROTOCOL_NAME  => 'Nucleic Acid Extraction';
Readonly my $SEPARATION_PROTOCOL_NAME  => 'Cell Separation';
Readonly my $RECRUITMENT_PROTOCOL_NAME => 'Recruitment';

sub BUILD {

    my ( $self, $params ) = @_;

    if ( my $conffile = $params->{'config_file'} ) {
        my $c = Config::YAML->new( config => $conffile );
        my $h = $c->get_MAGETAB();
        unless ( $h && ref $h eq 'HASH' ) {
            croak("Error: Config file does not contain a MAGETAB section.");
        }
        $self->_config($h);
    }

    # Create top-level investigation to contain some object definitions.

    # FIXME we'd be better off overriding the default output for
    # Writer::IDF, but that needs a fix in Bio::MAGETAB.
    my $idf  = $self->builder->find_or_create_investigation({
        title             => $self->_config()->{'investigation'}{'title'},
        description       => $self->_config()->{'investigation'}{'abstract'},
        publicReleaseDate => $self->_config()->{'investigation'}{'release_date'},
    });

    # We add a brief comment to indicate the dumping code versions.
    my $comment = $self->builder->find_or_create_comment({
        name   => 'MAGE-TAB Document Creator',
        value  => 'ClinStudy::Web v' . $ClinStudy::Web::VERSION
                . ' using Bio::MAGETAB v' . $Bio::MAGETAB::VERSION,
    });
    $idf->set_comments([$comment]);

    # FIXME add contact details.
    my @protocols;
    push @protocols, $self->_create_protocol( $HYB_PROTOCOL_NAME, 'hybridization' );
    push @protocols, $self->_create_protocol( $LABELING_PROTOCOL_NAME, 'labeling' );
    push @protocols, $self->_create_protocol( $EXTRACTION_PROTOCOL_NAME, 'nucleic_acid_extraction' );
    push @protocols, $self->_create_protocol( $SEPARATION_PROTOCOL_NAME, 'cell_separation' );
    push @protocols, $self->_create_protocol( $RECRUITMENT_PROTOCOL_NAME, 'recruitment' );
    $idf->set_protocols(\@protocols);

    $self->_investigation( $idf );
    
    return;
}

sub _create_protocol {

    my ( $self, $pname, $ptype ) = @_;

    my $type = $self->builder->find_or_create_controlled_term({
        category => 'ProtocolType',
        value    => $ptype,
    });
    my $proto = $self->builder->find_or_create_protocol({
        name => $pname,
        text => $self->_config()->{'protocols'}{$ptype},
        protocolType => $type,
    });

    return $proto;
}

sub dump {

    my ( $self ) = @_;

    my $sdrf_file = $self->_config()->{'investigation'}{'title'}
        or croak("Error: Config file must contain an investigation title value");

    $sdrf_file =~ s/[^A-Za-z0-9_-]+/_/g;
    $sdrf_file .= '.sdrf';

    # Sort objects into SDRFRows.
    my $sdrf = $self->builder->find_or_create_sdrf({
        uri => $sdrf_file,
    });
    $sdrf->add_nodes( [ $self->builder->get_magetab()->get_nodes() ] );

    $self->_investigation()->set_sdrfs([$sdrf]);

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
        warn(sprintf("Warning: ClinStudyWeb REST query returned error %s for %s %s\n",
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

    my ( $self, $filename, $xml_data_node ) = @_;

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

    # Hybridization
    my $hyb = $self->_create_hyb( $xml_data_node, $file );

    return $file;
}

sub _create_hyb {

    my ( $self, $xml_data_node, $file ) = @_;

    my $builder = $self->builder();

    my $ttype = $builder->find_or_create_controlled_term({
        category => 'TechnologyType',
        value    => 'hybridization',
    });

    my $hybid = $xml_data_node->getAttribute('identifier');
    my $hyb = $self->_create_node_and_edge(
        'assay',
        {
            name           => $hybid,
            technologyType => $ttype,
        },
        $file,
    );

    my $hyb_prot = $builder->get_protocol({ name => $HYB_PROTOCOL_NAME })
        or croak(qq{Error retrieving protocol named "$HYB_PROTOCOL_NAME".});
    my $hyb_pa_attrs = {
        protocol   => $hyb_prot,
        date       => $xml_data_node->getAttribute('batch_date'),
    };
    if ( my $op = $xml_data_node->getAttribute('operator') ) {
        $hyb_pa_attrs->{'performers'} = [ $builder->find_or_create_contact({
            lastName => $op,
        }) ];
    }

    foreach my $channel ( $xml_data_node->findnodes('./channels') ) {
        $self->_process_channel( $channel, $hyb, $hyb_pa_attrs );
    }

    return $hyb;
}

sub _process_channel {

    my ( $self, $channel, $hyb, $hyb_pa_attrs ) = @_;

    my $builder = $self->builder();

    my $label_str = $channel->getAttribute('label');
    my $label     = $builder->find_or_create_controlled_term({
        category => 'LabelCompound',
        value    => $label_str,
    });

    foreach my $sample ( $channel->findnodes('./sample' ) ) {

        my $sample_name = $sample->getAttribute('sample_name');
    
        my $le = $self->_create_node_and_edge(
            'labeled_extract',
            {
                name  => "$sample_name ($label_str)",
                label => $label,
            },
            $hyb,
            $hyb_pa_attrs,
        );
        $self->_process_sample( $sample, $le );
    }

    return;
}

sub _process_sample {

    my ( $self, $sample, $le ) = @_;

    my $sample_name = $sample->getAttribute('sample_name');

    my $builder = $self->builder();

    # N.B. MaterialType is set later on.
    my $ex = $self->_create_node_and_edge(
        'extract',
        {
            name  => $sample_name,
        },
        $le,
        {
            protocol   => ($builder->get_protocol({ name => $LABELING_PROTOCOL_NAME })
                or croak(qq{Error retrieving protocol named "$LABELING_PROTOCOL_NAME".})),
        },
    );

    # FIXME OrganismPart is blood.
    my $sa = $self->_create_node_and_edge(
        'sample',
        {
            name  => $sample_name,
        },
        $ex,
        {
            protocol   => ($builder->get_protocol({ name => $EXTRACTION_PROTOCOL_NAME })
                or croak(qq{Error retrieving protocol named "$EXTRACTION_PROTOCOL_NAME".})),
        },
    );

    # The patient, unrecruited.
    my $so = $self->_create_node_and_edge(
        'source',
        {
            name  => $sample->getAttribute('patient_number'),
        },
        $sa,
        {
            protocol   => ($builder->get_protocol({ name => $RECRUITMENT_PROTOCOL_NAME })
                or croak(qq{Error retrieving protocol named "$RECRUITMENT_PROTOCOL_NAME".})),
        },
        {
            protocol   => ($builder->get_protocol({ name => $SEPARATION_PROTOCOL_NAME })
                or croak(qq{Error retrieving protocol named "$SEPARATION_PROTOCOL_NAME".})),
        },
    );

    my ( @sample_chars, @source_chars );

    # We assume here that all samples are human.
    my $char = $builder->find_or_create_controlled_term({
        category => 'Organism',
        value    => 'Homo sapiens',
    });
    push @source_chars, $char;

    # FIXME config options
    my @sample_attr_names = qw(cell_type time_point visit_date);
    my @hidden_attr_names = qw();

    ATTR:
    foreach my $attr ( $sample->attributes() ) {
        my $attrname = $attr->name();

        # First, a couple of special cases.
        if ( $attrname eq 'material_type' ) {
            my $mt = $builder->find_or_create_controlled_term({
                category => 'MaterialType',
                value    => $attr->value(),
            });
            $ex->set_materialType($mt);
            next ATTR;
        }
        if ( $attrname eq 'entry_date' ) {
            if ( my $yob = $sample->getAttribute('year_of_birth') ) {
                my ( $entry_year ) = ( $attr->value =~ m/\A (\d{4}) /xms );
                my $age_str = $entry_year - $yob;
                my $age = $builder->find_or_create_controlled_term({
                    category => 'age_at_entry',
                    value    => $age_str,
                });
                push @source_chars, $age;
            }
            next ATTR;
        }

        # Skip anything flagged as hidden.
        next ATTR if ( first { $_ eq $attrname } @hidden_attr_names, 'year_of_birth', 'sample_name' );

        # Skip empty attributes.
        next ATTR if ( $attr->value() eq q{} );

        # For everything else, create controlled terms.
        my $char = $builder->find_or_create_controlled_term({
            category => $attr->name(),
            value    => $attr->value(),
        });

        # A handful of things relate to the sample; most attributes
        # pertain to the source (i.e. the patient).
        if ( first { $_ eq $attrname } @sample_attr_names ) {
            push @sample_chars, $char;
        }
        else {
            push @source_chars, $char;
        }
    }

    foreach my $eg_group ( $sample->findnodes('./emergent_group') ) {
        foreach my $attr ( $eg_group->attributes() ) {
            my $char = $builder->find_or_create_controlled_term({
                category => 'emergent_group.' . $attr->name(),
                value    => $attr->value(),
            });
            push @sample_chars, $char;
        }
    }
    foreach my $pg_group ( $sample->findnodes('./prior_group') ) {
        foreach my $attr ( $pg_group->attributes() ) {
            my $char = $builder->find_or_create_controlled_term({
                category => 'prior_group.' . $attr->name(),
                value    => $attr->value(),
            });
            push @source_chars, $char;
        }
    }
    foreach my $test_group ( $sample->findnodes('./test_result') ) {
        foreach my $attr ( $test_group->attributes() ) {
            my $char = $builder->find_or_create_controlled_term({
                category => 'test_result.' . $attr->name(),
                value    => $attr->value(),
            });
            push @source_chars, $char;
        }
    }

    $sa->set_characteristics( [ sort { $a->get_category cmp $b->get_category } @sample_chars ] );
    $so->set_characteristics( [ sort { $a->get_category cmp $b->get_category } @source_chars ] );
}

sub _create_node_and_edge {

    my ( $self, $nodetype, $node_attr, $target, @pa_attrs ) = @_;

    my $builder = $self->builder();

    # Create the node.
    my $maker = 'find_or_create_' . $nodetype;
    my $node  = $builder->$maker( dclone($node_attr) );

    # Create the edges also.
    my $edge = $builder->find_or_create_edge({
        inputNode  => $node,
        outputNode => $target,
    });

    # Any protocol information here (only one protocol per edge for
    # now).
    my @protoapps;
    foreach my $pa_attr ( @pa_attrs ) {
        push @protoapps, $builder->find_or_create_protocol_application( dclone($pa_attr) );
    }
    $edge->set_protocolApplications( \@protoapps ) if scalar @protoapps;

    return $node;
}
    
sub add_file {

    my ( $self, $filename ) = @_;

    my $xml_data_node = $self->_query_rest( 'assay_file', $filename );

    my $builder = $self->builder();

    # Data file
    my $file = $self->_create_datafile( $filename, $xml_data_node );

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

