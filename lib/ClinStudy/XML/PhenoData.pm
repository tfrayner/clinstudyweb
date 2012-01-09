#!/usr/bin/env perl
#
# Copyright 2012 Tim Rayner, University of Cambridge
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

package ClinStudy::XML::PhenoData;

use Moose;

use List::Util qw(first);
use Carp;

extends 'ClinStudy::XML::Builder';

has 'spreadsheet' => ( is       => 'ro',
                       isa      => 'ClinStudy::XML::Spreadsheet',
                       required => 1 );

sub BUILD {

    my ( $self, $params ) = @_;

    my @required = qw(Patient|trial_id Patient|entry_date Visit|date);

    # Check the spreadsheet to make sure it has the required columns.
    my @header = @{ $params->{'spreadsheet'}->header() };
    foreach my $term ( @required ) {
        unless ( first { $_ eq $term } @header ) {
            croak(qq{Error: required heading "$term" not found in input spreadsheet.\n});
        }
    }

    return;
}

sub read {

    my ( $self ) = @_;

    my $ss = $self->spreadsheet();

    while ( my $row = $ss->next_row() ) {
        my $phash   = { trial_id   => delete $row->{'Patient|trial_id'},
                        entry_date => delete $row->{'Patient|entry_date'} };
        my $vhash   = { date       => delete $row->{'Visit|date'} };
        my $patient = $self->update_or_create_element('Patient', $phash, $self->root());
        my $visit   = $self->update_or_create_element('Visit', $vhash, $patient);

        # Iterate over the rest of the data and create PhenotypeQuantities.
        while ( my ( $name, $value ) = each %$row ) {
            if ( $value && $value !~ /\A \s* \z/xms ) { # FIXME detect N/A etc.
                $name  =~ s/\A \s* (.*?) \s* \z/$1/xms;
                $value =~ s/\A \s* (.*?) \s* \z/$1/xms;
                $self->update_or_create_element( 'PhenotypeQuantity',
                                                 { type => $name, value => $value },
                                                 $visit );
            }
        }
    }

    return;
}

1;

__END__

=head1 NAME

ClinStudy::XML::PhenoData - XML generation from immunophenotyping spreadsheets.

=head1 SYNOPSIS

 use ClinStudy::XML::PhenoData;
 use ClinStudy::XML::Spreadsheet;
 my $reader = ClinStudy::XML::Spreadsheet->new({
     file => 'filename.txt',
 });
 my $builder = ClinStudy::XML::PhenoData->new({
     spreadsheet => $reader,
     schema      => $xsd,
 });

=head1 DESCRIPTION

Simple conversion of a spreadsheet containing many columns of
immunophenotyping data into ClinStudyML. Currently the database
requires that all values be expressed as real numbers. Three further
columns are required:

 Patient|trial_id
 Visit|date
 Patient|entry_date

Note that if you have the first two columns one can use the
TabReannotator class to retrieve the third, although you may need to
convert to plain tab-delimited text format to do so.

=head1 ATTRIBUTES

See L<ClinStudy::XML::Builder> for superclass attributes, some of
which are required.

=head2 spreadsheet

A ClinStudy::XML::Spreadsheet object to use to read in the data.

=head1 METHODS

=head2 read

Read in the data, and create an XML tree in memory.

=head2 dump

Write out the XML to disk (see the ClinStudy::XML::Builder superclass
for details).

=head1 SEE ALSO

L<ClinStudy::XML::Spreadsheet>, L<ClinStudy::XML::Builder>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

