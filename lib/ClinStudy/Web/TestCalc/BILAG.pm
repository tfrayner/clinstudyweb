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

use base qw( Class::Accessor::Fast );

use Scalar::Util qw( blessed );

# We want to keep this as generic as possible (although it's fine to
# use DBIx::Class), because we'll want to call it from other scripts
# outside of the main Catalyst environment. We still use context for
# the schema, though.
sub calculate {

    my ( $self, $container, $schema ) = @_;

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

    # Calculate the BILAG score here.
    my $score = 0;
    my @allresults;
    foreach my $testname ( @bilag_tests ) {
        my $test   = $schema->resultset('Test')->find({ name => $testname })
            or die(qq{Test "$testname" not found in database\n});
        my @results = $container->search_related(
            'test_results', {test_id => $test->id()} );
        my $count = scalar @results;
        
        unless ( $count == 1 ) {
            die(qq{Zero or many results for "$testname" found\n});
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
    elsif ( $contclass =~ / ::Hospitalisation \z/xms ) {
        $opts{ hospitalisation_id } = $container->id;
    }
    else {
        die("Cannot link test result to $contclass\n");
    }
    my $bilagtest = $schema->resultset('Test')->find_or_create({ name => 'BILAGPt' });
    my $bilag     = $schema->resultset('TestResult')->find_or_create({
        test_id => $bilagtest->id(),
        date    => $container->date(),
        %opts,
    });
    $bilag->set_column( 'value' => $score );
    $bilag->update();

    # Ensure the child test results are all linked to the BILAG.
    foreach my $child ( @allresults ) {
        $schema->resultset('TestAggregation')->find_or_create({
            test_result_id      => $child->id(),
            aggregate_result_id => $bilag->id(),
        });
    }

    return $is_valid;
}

1;
