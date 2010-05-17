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

package ClinStudy::XML::Builder;

use 5.008;

use strict; 
use warnings;

use Moose;
use Carp;

use Data::Dumper;
use List::Util qw(first);

our $VERSION = '0.01';

extends 'ClinStudy::XML::Schema';

has 'root'      => ( is       => 'ro',
                     isa      => 'XML::LibXML::Element',
                     required => 1,
                     default  => sub {
                         my $root = XML::LibXML::Element->new('ClinStudyML');
                         $root->setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
                         $root->setAttribute('xsi:noNamespaceSchemaLocation', 'clindb.xsd');
                         return $root;
                     } );

has 'document'  => ( is       => 'ro',
                     isa      => 'XML::LibXML::Document',
                     required => 1,
                     default  => sub { XML::LibXML::Document->new() } );

has 'is_strict' => ( is       => 'rw',
                     isa      => 'Bool',
                     required => 1,
                     default  => 1 );

sub BUILD {

    my ( $self, $params ) = @_;

    $self->document()->setDocumentElement( $self->root() );

    return;
}

sub find_or_create_group {
    
    # Create a grouping element.
    my ( $self, $class, $parent ) = @_;

    my @groups = $parent->getChildrenByTagName( $class );

    if ( scalar @groups == 0 ) {
        my $group = XML::LibXML::Element->new( $class );

	# Add $group to $parent after the appropriate preexisting group.
	my @other = $parent->getChildrenByTagName('*');

        if ( scalar @other == 0 ) {
            $parent->addChild( $group );
        }
        else {

            # If this group is the last in the series, we have to make
            # sure we actually add it.
            my $added;

            OTHER:
            foreach my $o ( @other ) {
                if ( ( $o->nodeName() cmp $class ) == 1 ) {
                    $parent->insertBefore( $group, $o );
                    $added++;
                    last OTHER;
                }
            }
            $parent->insertAfter( $group, $other[-1] ) unless $added;
        }

	return $group;
    }
    elsif ( scalar @groups == 1 ) {
        return $groups[0];
    }
    else {
        die("Error: Multiple child group elements found. We cannot choose!");
    }
}

# Note that some of these classes are just not really
# identifiable, due I guess to poor schema design (or impossible
# requirements?). These identifiers are only used within the scope of
# their parent elements, so that e.g. multiple patients could have a
# visit on the same date.
my %local_key_field = (
    AdverseEvent      => [ qw(type start_date) ],
    Assay             => [ qw(identifier) ],
    AssayBatch        => [ qw(date) ],
    AssayQcValue      => [ qw(name) ],
    Channel           => [ qw(label) ],
    ClinicalFeature   => [ qw(type) ],
    Comorbidity       => [ qw(condition_name date) ],
    Diagnosis         => [ qw(condition_name date) ], # Not really.
    DiseaseEvent      => [ qw(type start_date) ],
    Drug              => [ qw(name) ],
    EmergentGroup     => [ qw(name basis type) ],
    GraftFailure      => [ qw(date) ],
    Hospitalisation   => [ qw(date) ],
    Patient           => [ qw(trial_id) ],
    PriorGroup        => [ qw(name type) ],
    PriorObservation  => [ qw(type value date) ],
    PriorTreatment    => [ qw(type date days_uncertainty) ],
    RiskFactor        => [ qw(type) ],
    Sample            => [ qw(name) ],
    Study             => [ qw(type) ],
    SystemInvolvement => [ qw(type) ],
    TestResult        => [ qw(test date) ],
    Transplant        => [ qw(organ_type) ],  # Date is taken care of by Hospitalisation.
    Visit             => [ qw(date) ],
);

# Note that this is identical to that in ClinStudy::XML::Dumper;
my %irregular_plurals = (
    AssayBatch  => 'AssayBatches',
    Comorbidity => 'Comorbidities',
    Diagnosis   => 'Diagnoses',
    Study       => 'Studies',
);

sub _xml_escape {

    my ( $self, $string ) = @_;

    # Quote characters likely to cause a problem in queries.
    $string =~ s/&/&amp;/g;
    $string =~ s/</&lt;/g;
    $string =~ s/>/&gt;/g;
    $string =~ s/'/&apos;/g;
    $string =~ s/"/&quot;/g;

    return $string;
}


sub update_or_create_element {

    my ( $self, $class, $attrhash, $parent ) = @_;

    $parent ||= $self->root;

    my $groupname = $irregular_plurals{$class} || $class . 's';

    my @keyfields = @{ $local_key_field{ $class || [] } };
    unless ( scalar @keyfields ) {
        confess("Error: Unrecognised class $class has no key fields.");
    }

    my %key;
    foreach my $attrname ( keys %$attrhash ) {
        if ( first { $attrname eq $_ } @keyfields ) {
            $key{ $attrname } = $attrhash->{ $attrname };
            delete $attrhash->{ $attrname };
        }
    }
    foreach my $attrname ( @keyfields ) {
        unless( defined $key{ $attrname } ) {
            warn("Warning: undefined $class key field $attrname.\n");
        }
    }

    my $query = join (' and ', map { sprintf(qq{\@$_="%s"}, $self->_xml_escape($key{$_})) }
                               grep { defined $key{$_} }
                               keys %key);

    # Note that $query might be empty.
    my $xpath = qq{./$groupname/$class};
    if ( length $query ) {
        $xpath .= qq{\[$query\]};
    }
    my @objects = $parent->findnodes($xpath);

    my $is_undef = qr!\A (?:|unknown|n[\/\.]?[adk]) \z!ixms;

    my $obj;
    if ( scalar @objects == 1 ) {
        $obj = $objects[0];
    }
    elsif ( scalar @objects == 0 ) {

        $obj = XML::LibXML::Element->new($class);
        while ( my ( $key, $val ) = each %key ) {
            $obj->setAttribute($key, $val)
                if ( defined $val && $val !~ $is_undef );
        }

        my $groupelem = $self->find_or_create_group( $groupname, $parent );
	$groupelem->addChild($obj); # Order here is not important.
    }
    else {
        confess("Error: Multiple elements returned by XPath query $xpath");
    }

    # This is update_or_create, so we'd better update non-key attributes.
    while ( my ( $key, $val ) = each %$attrhash ) {
        $obj->setAttribute($key, $val)
            if ( defined $val && $val !~ $is_undef );
    }

    return $obj;
}

sub validate {

    my ( $self ) = @_;

    return $self->SUPER::validate( $self->document() );
}

sub dump {

    my ( $self, $fh ) = @_;

    $fh ||= \*STDOUT;

    if ( ! $self->is_strict() || $self->validate() ) {
        print $fh $self->document()->toString(1);
    }
    else {
        croak("Error: Generated XML document does not conform to schema.\n");
    }

    return;
}

1;
__END__

=head1 NAME

ClinStudy::XML::Builder - Utility module for creating ClinStudyML documents.

=head1 SYNOPSIS

 use ClinStudy::XML::Builder;
 my $builder = ClinStudy::XML::Builder->new();
 my $root    = $builder->root();

 # Add nodes as appropriate.

 # Output the finished document.
 $builder->dump( \*STDOUT );

=head1 DESCRIPTION

A (hopefully) convenient module that can be used to provide the common
framework required by a ClinStudyML document. It also provides some
utility methods that can be used to add elements and attributes to the
nascent document.

=head2 ATTRIBUTES

Note that XML schema attributes are handled by the
C<ClinStudy::XML::Schema> superclass.

=over 2

=item root

The root node of the XML document. This defaults to a ClinStudyML node
with the appropriate attributes.

=item document

The top-level XML::LibXML::Document object. Typically you won't need to access this.

=item is_strict

A flag indicating whether to validate the output XML against the
schema or not (default is true).

=back

=head2 METHODS

=over 2

=item dump( $fh )

Inserts the root node into a new XML::LibXML::Document object,
validates it against the schema, and writes the XML out to the
supplied filehandle (or STDOUT as default).

=item validate

Validates the in-memory XML document against the schema, returns true
if valid.

=item update_or_create_element( $class, $attrhash, $parent )

Method which takes a ClinStudyML element name (e.g. 'Patient'), a
hashref of attributes, and a parent XML::LibXML::Element, and either
creates a new child element or returns a pre-existing one. Note that
this method handles the creation of grouping elements
(e.g. 'Patients') for you, so you can effectively ignore them. If the
parent element is omitted the root element will be used as a default.

=item find_or_create_group( $class, $parent )

This method takes the desired element class name for a grouping
element (e.g. 'Patients') and a parent XML::LibXML::Element object and
either returns the appropriate element associated with $parent, or
creates a new element and attaches it to $parent for you.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

