#!/usr/bin/env perl
#
# Copyright 2011 Tim Rayner, University of Cambridge
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

package ClinStudy::XML::Spreadsheet;

use Moose;

use Spreadsheet::Read qw(ReadData rows);

has 'file'      => ( is       => 'ro',
                     isa      => 'Str',
                     required => 1 );

has 'delimiter' => ( is       => 'ro',
                     isa      => 'Str',
                     required => 1,
                     default  => ',' );

has '_data'     => ( is       => 'rw',
                     isa      => 'ArrayRef[ArrayRef]',
                     required => 1,
                     default  => sub { [[]] } );

has '_header'   => ( is       => 'rw',
                     isa      => 'ArrayRef',
                     required => 1,
                     default  => sub { [[]] } );

has '_rownum'   => ( is       => 'rw',
                     isa      => 'Int',
                     required => 1,
                     default  => 0 );

sub BUILD {

    my ( $self, $params ) = @_;

    # Currently using this iterator class has no memory advantages,
    # but it does provide a convenient facade pattern so that future
    # improvements to Spreadsheet::Read (or whatever) can be included
    # fairly seamlessly.
    my $ref = ReadData( $self->file(), sep => $self->delimiter(), cells => 0 );

    warn(sprintf("Parsing %s file with %s version %s...\n",
                 map { $ref->[0]->{$_} } qw( type parser version )));

    if ( scalar @$ref > 2 ) {
        warn("Warning: File contains multiple worksheets. Only the first will be parsed.\n");
    }

    my @rows = rows( $ref->[1] );

    HEADERROW:
    while ( my $row = shift @rows ) {
        my $hstr = join(q{}, map { defined $_ ? $_ : q{} } @$row);
        next HEADERROW if $hstr =~ /\A \s* \#/xms;
        $self->_header( $row );
        last HEADERROW;
    }

    unless( scalar @{ $self->_header() } > 0 ) {
        die("Error: Unable to find header row in file.");
    }

    my @data;

    BODYROW:
    foreach my $row ( @rows ) {
        my $bstr = join(q{}, map { defined $_ ? $_ : q{} } @$row);
        next BODYROW if $bstr =~ /\A \s* \#/xms;
        push @data, $row;
    }

    $self->_data( \@data );
}

sub next_row {

    my ( $self ) = @_;

    my $num = $self->_rownum();
    if ( $num > $#{ $self->_data() } ) {
        return undef;
    }

    my %row;
    @row{ @{ $self->_header() } } = @{ $self->_data()->[ $num ] };

    $self->_rownum($num + 1);

    return \%row;
}

1;

__END__

=head1 NAME

ClinStudy::XML::Spreadsheet - Iterator class used to scan through spreadsheets.

=head1 SYNOPSIS

 use ClinStudy::XML::Spreadsheet;
 my $reader = ClinStudy::XML::Spreadsheet->new({
     file => 'filename.txt',
 });
 while ( my $row = $reader->next_row() ) {
    # Do something with the $row hashref.
 }

=head1 DESCRIPTION

This is a utility class used to convert the output of the CPAN
Spreadsheet::Read module into a simpler form for use with our local
systems.

Currently this class requires the input file to contain just one
worksheet with a single line of column headings. Lines beginning with
the comment character ("#") are ignored.

=head1 ATTRIBUTES

=head2 file

The spreadsheet file to read. This can be in any format supported by
the CPAN Spreadsheet::Read module (CSV, Excel, OpenOffice etc.).

=head1 METHODS

=head2 next_row

Return a hashref representing the next spreadsheet row; keys are
column names, values are from the row itself.

=head1 SEE ALSO

Spreadsheet::Read on CPAN

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

