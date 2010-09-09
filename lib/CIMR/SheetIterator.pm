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

package CIMR::SheetIterator;

use Moose;
use Carp;
use DateTime::Format::Excel;

has 'sheet' => (is       => 'ro',
                isa      => 'Spreadsheet::ParseExcel::Worksheet',
                required => 1);

has '_previousRow' => (is     => 'rw',
                      isa    => 'Int');

has '_maxRow'     => (is     => 'rw',
                      isa    => 'Int');

has '_minCol'     => (is     => 'rw',
                      isa    => 'Int');

has '_maxCol'     => (is     => 'rw',
                      isa    => 'Int');

has 'header'      => (is     => 'rw',
                      isa    => 'ArrayRef[Str]');

sub BUILD {

    my ( $self, $params ) = @_;

    my $sheet = $self->sheet();

    my ( $minRow, $maxRow ) = $sheet->RowRange();
    my ( $minCol, $maxCol ) = $sheet->ColRange();

    croak("Invalid rows in sheet") if ( $maxRow < $minRow+1 );
    croak("Invalid columns in sheet") if ( $maxCol < $minCol );

    my @header;
    foreach my $col ($minCol ..  $maxCol) {
        my $cell = $sheet->Cell($minRow, $col);
        push @header, $cell ? $cell->value : q{};
    }

    $self->_previousRow($minRow);
    $self->_maxRow($maxRow);
    $self->_minCol($minCol);
    $self->_maxCol($maxCol);

    $self->header(\@header);
}

sub next {

    my ( $self ) = @_;

    my $sheet = $self->sheet();
    my $row   = $self->_previousRow() + 1;

    return if $row > $self->_maxRow();

    my @line;
    foreach my $col ( $self->_minCol() ..  $self->_maxCol() ) {
        my $cell = $sheet->Cell($row, $col);
        if ( $cell ) {
            if ( $cell->{Type} eq 'Date' ) {
                my $dt = DateTime::Format::Excel->parse_datetime( $cell->{Val} );
                push @line, $dt->ymd('-');
            }
            else {
                push @line, $cell->value;
            }
        }
        else {
            push @line, q{};
        }
    }

    my %data;
    @data{ @{ $self->header() } } = @line;

    $self->_previousRow($row);

    return \%data;
}

1;

=head1 NAME

CIMR::SheetIterator - Simple iterator class for Excel spreadsheets

=head1 SYNOPSIS

 use CIMR::SheetIterator;
 my $iter = CIMR::SheetIterator->new(sheet => $sheet);
 my $header = $iter->header();
 
 while ( my $row = $iter->next() ) {
     # do stuff with $row hashref
 }

=head1 DESCRIPTION

This is a fairly simple iterator class designed to make reading data
from an Excel spreadsheet just that little bit more pleasurable. The
constructor code assumes that the first line in the sheet is a header
line, and it uses the column names found in this line to index the
data for every subsequent line.

=head1 ATTRIBUTES

=head2 sheet

The Spreadsheet::ParseExcel::Worksheet object to use for input.

=head1 METHODS

=head2 next

Returns a hashref containing the values from the next line, keyed by
the column headings found in the first line of the sheet.

=head1 SEE ALSO

Spreadsheet::ParseExcel

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

