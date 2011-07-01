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

package ClinStudy::XML::TabDrugReader;

use ClinStudy::XML::TabReader;
use Moose;
extends 'ClinStudy::XML::TabReader';

use Parse::RecDescent;

my $GRAMMAR = join('', <DATA>);
$Parse::RecDescent::skip = ' *';
$::RD_ERRORS++;       # unless undefined, report fatal errors
$::RD_WARN++;         # unless undefined, also report non-fatal problems
$::RD_HINT++;         # if defined, also suggestion remedies

has 'rec_descent' => ( is       => 'ro',
                       isa      => 'Parse::RecDescent',
                       required => 1,
                       default  => sub { Parse::RecDescent->new($GRAMMAR); } );

sub recursive_cols_to_elements {

    my ( $self, $colhash, $tree, $parent, $level ) = @_;

    $parent ||= $self->root;
    
    # Try to do this safely.
    unless ( $level++ < 100 ) {
	die("Error: deep recursion in column processing.");
    }

    foreach my $class ( keys %$tree ) {

        if ( $class eq 'Drug' ) {

            # Columns named "Drugs" are a special case. Note that
            # we're not supporting other "Drug|*" columns in this
            # subclass.
            my @drughashes;
            if ( my $value = $colhash->{'Drugs'} ) {
                $self->_used()->{ 'Drugs' }++;
                
                # Add the value to the element attribute hash.
                if ( defined $value && $value ne q{} ) {

                    # Ensure there's a trailing record delimiter.
                    $value =~ s/;? \s* \z/;/xms;

                    # Attempt to parse the Drug data.
                    my $parsed = $self->rec_descent()->drug_list( $value )
                        or die("Unable to parse drug string on line $..");

                    # Map the returned AoA structure onto a hashref
                    # appropriate for XML element building.
                    foreach my $item ( @$parsed ) {

                        my $elem = $self->update_or_create_element(
                            $class,
                            {
                                name      => $item->[0],
                                dose      => $item->[1][0],
                                dose_unit => $item->[1][1],
                                dose_freq => $item->[2],
                                dose_regime => $item->[3],
                            },
                            $parent,
                        );

                        # Recursion time.
                        $self->recursive_cols_to_elements(
                            $colhash, $tree->{ $class }, $elem, $level );
                    }
                }
            }
        }
        else {

            # Regular case; aggregate class attributes into a single
            # hash, then find or create it.
            my %attrhash;
            while ( my ( $key, $value ) = each %$colhash ) {
                my ( $col_class, $attrname ) = split /\|/, $key;
                if ( $col_class && $col_class eq $class ) {
                    
                    # Record that we've at least considered this column.
                    $self->_used()->{ $key }++;
                    
                    # Add the value to the element attribute hash.
                    if ( defined $value && $value ne q{} ) {
                        $attrhash{ $attrname } = $value;
                    }
                }
            }

            if ( scalar grep { defined $_ } values %attrhash ) {
                my $elem = $self->update_or_create_element( $class, \%attrhash, $parent );
        
                # Recursion time.
                $self->recursive_cols_to_elements( $colhash, $tree->{ $class }, $elem, $level );
            }
        }
    }
    
    return;
}

1;

=head1 NAME

ClinStudy::XML::TabDrugReader - Specialised module for creating ClinStudyML documents.

=head1 SYNOPSIS

 use ClinStudy::XML::TabDrugReader;
 my $builder = ClinStudy::XML::TabDrugReader->new({
     tabfile => 'filename.txt',
 });
 my $root    = $builder->root();

 $builder->read();

 # Output the finished document.
 $builder->dump( \*STDOUT );

=head1 DESCRIPTION

This subclass of the ClinStudy::XML::TabReader class is intended to
facilitate parsing of tab-delimited documents in which the Drug
information has not been formally split into the components required
by the ClinStudyWeb schema. A recursive-descent grammar is used to
parse strings containing Drug information into drug name, dosage and
dose frequency data.

=head1 ATTRIBUTES AND METHODS

See the C<ClinStudy::XML::TabReader> and C<ClinStudy::XML::Builder>
superclasses.

=head1 SEE ALSO

L<ClinStudy::XML::Builder>, L<ClinStudy::XML::TabReader>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

# Here's where the magic happens.

__DATA__

drug_list:       drug_item(s) end_of_line

                 { $item[1] }

                 | <error: Unable to parse drug_list starting here: $text>

drug_item:       drug_date(?) drug_name drug_dosage(?) drug_frequency(?) dose_regime(?) delimiter

                 { [ $item[2], $item[3][0], $item[4][0], $item[5][0] ] }

                 | <error: Unable to parse drug_item starting here: $text>

drug_dosage:     number dosage_unit

                 { [ $item[1], $item[2] ] }

drug_frequency:  /od|bd|tds|qds|prn|weekly|3x \/ wk|2x \/ wk|hourly|mane|nocte|every 2 weeks|alt(?:ernate)? days/

dosage_unit:     /mg|ug|mcg|g|iu|tablets?|puffs?|ml/

number:          /[0-9]+(?:\.[0-9]+)?/

drug_name:       drug_part(s)

                 { join(' ', @{ $item[1] }) }

                 | <error: Unable to parse drug_name starting here: $text>

drug_attr:       drug_dosage | drug_frequency

# Keep this negative lookahead in sync with the drug_item rule.
drug_part:       ...!drug_attr /[\w-]+/

drug_date:       /\d{2}\/\d{2}\/\d{4}/

dose_regime:     /[^\;]+/ ...delimiter

                 { $item[1] }

                 | <error: Unable to parse dose_regime starting here: $text>

delimiter:       /;/

end_of_line:     /\Z/

