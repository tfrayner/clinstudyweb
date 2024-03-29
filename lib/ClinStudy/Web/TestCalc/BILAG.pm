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

package ClinStudy::Web::TestCalc::BILAG;

use strict;
use warnings;

use Moose;

extends 'ClinStudy::Web::TestCalc';

use Scalar::Util qw( blessed );
use List::Util qw( first );

# We want to keep this as generic as possible (although it's fine to
# use DBIx::Class), because we'll want to call it from other scripts
# outside of the main Catalyst environment. We still use context for
# the schema, though.
sub calculate {

    my ( $self, $container, $schema, $c ) = @_;

    # This will only go wrong if not all the tests have been filled in.
    my $is_valid = 1;

    my @bilag_tests = qw(
        GeneralCat
        MucocutCat
        NeuroCat
        MuscuCat
        CardioCat
        VascuCat
        RenalCat
        HaemaCat
    );

    my %score_map = (
        'A' => 9,
        'B' => 3,
        'C' => 1,
        'D' => 0,
        'E' => 0,
    );

    # Pre-check that we have all the results, or none of the results.
    my @exists = map { $self->check_result_existence( $schema, $container, $_ ) } @bilag_tests;
    if ( ( defined ( first { defined $_ && $_ == 1 } @exists ))
      && ( defined ( first { defined $_ && $_ != 1 } @exists )) ) {
        die("Error: Some but not all results present for BILAG.\n");
    }

    # Calculate the BILAG score here.
    my $score = 0;
    my @allresults;
    foreach my $testname ( @bilag_tests ) {

        my @results = $container->search_related(
            'test_results',
            { 'test_id.name' => $testname },
            { join => 'test_id', prefetch => 'test_id' } );
        my $count = scalar @results;
        
        unless ( $count == 1 ) {

            # Raising an exception here is overkill (some visits just
            # have no BILAG score); instead we just return undef.
            return;
        }

        push @allresults, $results[0];
        if ( my $value = $results[0]->controlled_value_id() ) {
            my $code   = $value->value;
            my $number = $score_map{ uc $code };
            if ( defined $number ) {
                $score += $number;
            }
            else {
                die(qq{BILAG Score code "$code" not recognised\n} );
            }
        }
        else {
            die(qq{Test result for "$testname" not linked to controlled value\n} );
        }
    }

    # If we've got this far, $score is the final BILAG.
    my %opts;
    my $contclass = blessed $container;
    if ( $contclass =~ / ::Visit \z/xms ) {
        $opts{ visit_id } = $container->id;
    }
    else {
        die("Cannot link test result to $contclass\n");
    }

    $c->_set_journal_changeset_attrs();
    $schema->txn_do (
        sub {
            my $bilagtest = $schema->resultset('Test')->find_or_create({ name => 'BILAGPt' });
            my $bilag     = $schema->resultset('TestResult')->find_or_new({
                test_id => $bilagtest->id(),
                date    => $container->date(),
                %opts,
            });
            unless ( defined $bilag->value() && $bilag->value() eq $score ) {
                $bilag->set_column( 'value' => $score );
                $bilag->update_or_insert();
            }

            # Ensure the child test results are all linked to the BILAG.
            foreach my $child ( @allresults ) {
                $schema->resultset('TestAggregation')->find_or_create({
                    test_result_id      => $child->id(),
                    aggregate_result_id => $bilag->id(),
                });
            }
        }
    );

    return $is_valid;
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;

__END__

=head1 NAME

ClinStudy::Web::TestCalc::BILAG - Calculation of SLE BILAG scores

=head1 SYNOPSIS

 use ClinStudy::Web::TestCalc::BILAG;

=head1 DESCRIPTION

This TestCalc module is designed to convert the per-system scores
defined by BILAG version 3 (Hay E.M. et al. (1993) The BILAG index: a
reliable and valid instrument for measuring clinical disease activity
in systemic lupus erythematosus. Q J Med. 86(7):447-58. PubMed ID:
8210301) into a numerical index (named "BILAGPt" in the database). The
index is calculated by converting the A-E BILAG scores into integers
and then calculating the sum:

 A  =>  9
 B  =>  3
 C  =>  1
 D  =>  0
 E  =>  0

These scores were found to agree entirely with those calculated by the
BLIPS software (Isenberg D.A., Gordon C.; BILAG Group. British Isles
Lupus Assessment Group (2000) From BILAG to BLIPS--disease activity
assessment in lupus past, present and
future. Lupus 9(9):651-4. PubMed ID: 11199918). Discussion of
this index calculation system may be found in Cresswell L. et
al. (2009; Numerical scoring for the Classic BILAG index. Rheumatology
(Oxford) 48(12):1548-52 PubMed ID: 19779027). However, the
original source reference has proven elusive.

=head1 METHODS

=head2 calculate

The method used by the C<ClinStudy::Web::TestCalc> superclass to
create a new aggregate test result in the database, or update the old
result. See the superclass documentation for more details.

=head1 SEE ALSO

L<ClinStudy::Web::TestCalc>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

