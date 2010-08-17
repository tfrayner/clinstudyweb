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

package CIMR::Parser::ARR;

use 5.008;

use Moose;
use XML::LibXML;
use Carp;

use MooseX::Types::Moose qw( Str HashRef );
use CIMR::Types qw( Date );

has 'arr_file'        => (is       => 'rw',
                          isa      => Str,
                          required => 1 );

has 'cel_file'        => (is       => 'rw',
                          isa      => Str,
                          required => 0 );

has 'array_name'      => (is       => 'rw',
                          isa      => Str,
                          required => 0 );

has 'batch_name'      => (is       => 'rw',
                          isa      => Str,
                          required => 0 );

has 'creation_date'   => (is       => 'rw',
                          isa      => Date,
                          coerce   => 1,
                          required => 0 );

has 'scan_date'       => (is       => 'rw',
                          isa      => Date,
                          coerce   => 1,
                          required => 0 );

has 'operator'        => (is       => 'rw',
                          isa      => Str,
                          required => 0 );

has 'user_attributes' => (is       => 'rw',
                          isa      => HashRef,
                          required => 1,
                          default  => sub { {} } );

sub BUILD {

    my ( $self, $params ) = @_;

    # Check the file exists.
    unless ( -r $self->arr_file() ) {
        croak( "File not found or unreadable: " . $self->arr_file() );
    }

    # Parse the file immediately upon instantiation (since they're
    # generally small, why not).
    $self->_parse();

    return;
}

sub _parse {

    my ( $self ) = @_;

    my $parser  = XML::LibXML->new();
    my $xp      = $parser->parse_file($self->arr_file());
    my $rootset = $xp->find('/ArraySetFile');
    if ( $rootset->size() != 1 ) {
        croak("Error: ARR file must contain only one ArraySetFile entry");
    }
    my $root = $rootset->get_node(0);

    # Check file version and type.
    my $version = $root->findvalue('@Version');
    if ( $version ne '1.0' ) {
        croak("Unsupported ARR file version: $version");
    }
    my $type = $root->findvalue('@Type');
    if ( $type ne 'affymetrix-calvin-arraysetfile' ) {
        croak("Unsupported ARR file type: $type");
    }

    # Check ARR file creation step (this is probably more a warning-type situation if wrong).
    my $creation_step = $root->findvalue('@CreatedStep');
    if ( $creation_step ne 'Scanning' ) {
        carp("Warning: Unusual creation step: $creation_step.\n");
    }

    # Set our interesting attributes here.
    $self->batch_name($root->findvalue('@OriginalProjectName'));

    $self->creation_date($root->findvalue('@CreatedDateTime'));

    $self->_parse_arrays( $root );

    $self->_parse_user_attrs( $root );

    return;
}

sub _parse_arrays {

    my ( $self, $parent ) = @_;

    # Only one array per ARR file is supported at this time (we need
    # to figure out the use cases for multiple arrays per file; would
    # these be multiple scans or hybs of the same sample? We
    # absolutely can't support multiple samples per file).
    my $arrayset = $parent->find('./PhysicalArrays/PhysicalArray');
    if ( $arrayset->size() != 1 ) {
        croak("Error: ARR file must contain only one PhysicalArray section");
    }
    my $array = $arrayset->get_node(0);

    my $cel = $array->findvalue('@ArrayName');

    $self->array_name($cel);

    unless ( $cel ) {
        croak("Error: No ArrayName attribute found.");
    }

    # If we happen to have the CEL files in the current working
    # directory we can check the case of the filename extension. NOTE
    # however that this gives unpredictable results when used on a
    # case-insensitive file system, so we no longer try to be
    # clever. if this becomes an issue consider reading the directory
    # directly using readdir.
    
#    if ( -r $cel . '.cel' ) {
#        $cel .= '.cel';
#    }
#    else {

        # This is the default.
        $cel .= '.CEL';
#    }
    $self->cel_file( $cel );

    $self->_parse_array_attrs( $array );

    return;
}

sub _parse_array_attrs {

    my ( $self, $parent ) = @_;

    my $attrset = $parent->find('./ArrayAttribute');

    my ( $operator, $date );
    foreach my $attr ( $attrset->get_nodelist() ) {

        $operator = $attr->string_value()
            if ($attr->findvalue('@Name') =~ /^hybwash operator|Fluidics Operator$/);

        $date     = $attr->string_value()
            if ($attr->findvalue('@Name') eq 'Fluidics Date');
    }

    unless ( $operator && $date ) {
        die(sprintf("Error: Both Operator and Date fields must contain a value (%s).\n",
                    $self->arr_file));
    }

    $self->operator( $operator );
    $self->scan_date( $date );

    return;
}

sub _parse_user_attrs {

    my ( $self, $parent ) = @_;

    my $attrset = $parent->find('./UserAttributes/UserAttribute');

    my %user_attr;
    foreach my $attr ( $attrset->get_nodelist() ) {
        my $name  = $attr->findvalue('@Name');
        my $value = $attr->string_value();

        # Strip whitespace.
        $value =~ s/\A\s*(.*?)\s*\z/$1/xms;

        # Auto-detect date types and coerce to a DateTime object.
        if ( $attr->findvalue('@Type') eq 'Date' && $value ) {

            # ARR files apparently store dates in US format
            # (MM/DD/YYYY), which just happens to be the default for
            # DateTime::Format::DateManip.
            $value = to_Date($value)
                or croak("Cannot coerce date string to object.");
        }

        $user_attr{ $name } = $value;
    }

    $self->user_attributes( \%user_attr );

    return;
}

no Moose;

1;

__END__

=head1 NAME

CIMR::Parser::ARR - Parsing Affymetrix ARR files

=head1 SYNOPSIS

 use CIMR::Parser::ARR;
 my $arr  = CIMR::Parser::ARR->new( arr_file => $file );
 my $attr = $arr->user_attributes();

=head1 DESCRIPTION

This module is a simple parser for the XML-based ARR file format from
Affymetrix.

=head1 METHODS

=over 2

=item new

The object constructor. The object is completely instantiated,
including the ARR file parsing step, during object construction. No
other method calls are required.

=back

=head1 ATTRIBUTES

=over 2

=item arr_file

The name of the ARR file to parse. This must be passed in upon object
instantiation, and the ARR file must reside in the current working
directory.

=item cel_file

The name of the CEL file to which the ARR file corresponds. At the
moment the code assumes that CEL files have a ".CEL" filename
extension (as opposed, for example, to ".cel").

=item array_name

The core array identifier ("ArrayName" in the ARR file) associated
with the ARR file. This corresponds to the CEL file name with the
".CEL" extension removed, which may be of interest if your CEL
filenames have different extensions.

=item batch_name

The Assay batch name ("OriginalProjectName" in the ARR file).

=item creation_date

The date upon which the ARR file was created ("CreatedDateTime" in the
ARR file).

=item scan_date

The date on which the hybridized chip was scanned (the "Fluidics Date"
ArrayAttribute in the ARR file).

=item operator

The human operator registered with the system (the "hybwash operator"
or "Fluidics Operator" ArrayAttribute in the ARR file).

=item user_attributes

A hashref of user-defined attributes included in the original sample
registration spreadsheet.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

