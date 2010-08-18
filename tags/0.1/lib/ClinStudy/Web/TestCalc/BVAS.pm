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

package ClinStudy::Web::TestCalc::BVAS;

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

    # General structure is: system => [ max bvasNW, max bvasP,
    #                                    { test1 => [bvasNW, bvasP], test2=>...}
    #                                 ],...
    my %bvas_test = (
        'General' =>
            [ 2, 3,
              {
                  SNone =>       undef,
                  Smalaise =>    [1,1],
                  Smyalgia =>    [1,1],
                  Sarthralgia => [1,1],
                  Sheadache =>   [1,1],
                  Sfeverlow =>   [1,1],
                  Sfeverhigh =>  [2,2],
                  Swtloss =>     [2,2],
              },
         ],
        'Cutaneous' =>
            [ 3, 6,
              {
                  Cnone =>      undef,
                  Cinfarct =>   [1,2],
                  Cpurpura =>   [1,2],
                  Cother =>     [2,2],
                  Culcer =>     [1,4],
                  Cgangrene =>  [1,6],
                  Cmultiple =>  [2,6],
              },
          ],
        'Mucous membranes/eyes' =>
            [ 3, 6,
              {
                  Mnone =>          undef,
                  Mophthopinion =>  undef,
                  Mophthinactive => undef,
                  Mmulcer =>        [1,1],
                  Mgulcer =>        [1,1],
                  Mproptosis =>     [2,4],
                  Mconjunc =>       [1,1],
                  Mepi =>           [1,2],
                  Mblur =>          [2,3],
                  Mvloss =>         [0,6],
                  Mophthuveitis =>  [0,6],
                  Mophthexudates => [0,6],
                  Mophthhaem =>     [0,6],
              },
          ],
        'ENT' =>
            [ 3, 6,
              {
                  Enone =>       undef,
                  Eopinion =>    undef,
                  Einactive =>   undef,
                  Eobs =>        [1,2],
                  Eblood =>      [2,4],
                  Ecrust =>      [2,4],
                  Esinus =>      [1,2],
                  Edeaf =>       [0,3],
                  Estridor =>    [2,5],
                  Egransinus =>  [0,4],
                  Econddeaf =>   [0,3],
                  Esensdeaf =>   [0,6],
                  Esubglottic => [0,6],
              },
          ],
        'Chest' =>
            [ 3, 6,
              {
                  Chnone =>       undef,
                  ChCXR =>        undef,
                  Chinactive =>   undef,
                  Chcough =>      [1,2],
                  Chdysp =>       [1,2],
                  Chhaemop =>     [1,3],
                  Chnodules =>    [0,3],
                  Chpleural =>    [0,4],
                  Chinfiltrate => [0,4],
                  Chbighaemop =>  [0,6],
                  Chrespfail =>   [3,6],
              },
          ],
        'Cardiovascular' =>
            [ 3, 6,
              {
                  Cvnone =>         undef,
                  Cvopinion =>      undef,
                  Cvinactive =>     undef,
                  CvAR =>           [2,4],
                  Cvpericardial =>  [2,3],
                  Cvischaemic =>    [2,4],
                  Cvcongestive =>   [2,4],
                  Cvpericarditis => [0,4],
                  CvMI =>           [0,6],
                  Cvcardiomyop =>   [0,6],
              },
          ],
        'Abdominal' =>
            [ 4, 9,
              {
                  Anone =>         undef,
                  Asurgical =>     undef,
                  Ainactive =>     undef,
                  Apain =>         [2,3],
                  Adiarrhoea =>    [2,3],
                  Agutperf =>      [0,9],
                  Apancreatitis => [0,9],
              },
          ],
        'Renal' =>
            [ 6, 12,
              {
                  Rnone =>        undef,
                  RBP =>          [1,4],
                  Rproteinuria => [2,4],
                  Rhaematuria =>  [3,6],
                  CreatValue =>   {   # Special case.
                      125 => [2,4],
                      250 => [3,6],
                      500 => [4,8],
                  },
                  Rcreatrise =>   [0,6],
              },
          ],
        'Nervous system' =>
            [ 6, 9,
              {
                  Nnone =>         undef,
                  Nconfusion =>    [1,3],
                  Nseizure =>      [3,9],
                  Nstroke =>       [3,9],
                  Ncord =>         [3,9],
                  Nneurop =>       [3,6],
                  Ncranial =>      [3,6],
                  Nmononeuritis => [3,9],
              },
          ],
    );

    # Pre-check that we have all the results, or none of the results.
    while ( my ( $system, $sysdata ) = each %bvas_test ) {
        my ( $max_bvasP, $max_bvasNW, $subtest ) = @{ $sysdata };

        # Note that CreatValue is allowed to be missing.
        my @exists = map { $self->check_result_existence( $schema, $container, $_ ) }
            grep { $_ ne 'CreatValue' }
            keys %{ $subtest };
        if ( ( defined ( first { defined $_ && $_ == 1 } @exists ))
          && ( defined ( first { defined $_ && $_ != 1 } @exists )) ) {
            die("Error: Some but not all results present for BVAS.\n");
        }
    }

    # Calculate the BVAS score here.
    my ( $bvas_scoreP, $bvas_scoreNW );
    my @allresults;
    while ( my ( $system, $sysdata ) = each %bvas_test ) {
        my ( $max_bvasP, $max_bvasNW, $subtest ) = @{ $sysdata };
        my @systests;
        my $sysscoreP = my $sysscoreNW = 0;
        TEST:
        foreach my $testname ( keys %{ $subtest } ) {

            my @results = $container->search_related(
                'test_results',
                { 'test_id.name' => $testname },
                { join => 'test_id', prefetch => 'test_id' } );
            my $count = scalar @results;
        
            unless ( $count == 1 ) {
                next TEST if ( $count == 0 && $testname eq 'CreatValue' );  # Special case.

                # Raising an exception here is overkill (some visits
                # just have no BVAS score); instead we just return
                # undef.
                return;
            }

            my $testdata = $subtest->{ $testname };
            if ( ref $testdata eq 'ARRAY' ) {

                # Most tests
                my $value = $results[0]->controlled_value_id();
                unless ( defined $value ) {
                    die(qq{Test result for "$testname" not linked to controlled value\n} );
                }

                if ( $value->value() =~ /\A new [ ]* (?:\/|or) [ ]* worse \z/ixms ) {
                    $sysscoreNW += $testdata->[1];
                }
                elsif ( $value->value() =~ /\A (?:present|persistent) \z/ixms ) {
                    $sysscoreP  += $testdata->[0];
                }
            }
            elsif ( ref $testdata eq 'HASH' ) {

                # CreatValue only
                my $value = $results[0]->value();
                unless ( defined $value ) {
                    die(qq{Test result for "$testname" not linked to value\n} );
                }

                LEVEL:
                foreach my $level ( reverse sort keys %{ $testdata } ) {
                    if ( $value >= $level ) {

                        # FIXME I'm afraid I don't quite understand
                        # how this should work. Since the form looks
                        # as though it's only recording new/worse
                        # that's all I'm counting. The score sheet,
                        # however, suggests there should be scoring
                        # for BVAS2 (persistent) as well.
                        $sysscoreNW += $testdata->{ $level }[1];
                        last LEVEL;
                    }
                }                
            }

            push @systests, $results[0];
        }

        # FIXME somewhere in here we need to validate the *none fields
        # against everything else in a given system.

        # Don't go over the maximum score for this system.
        if  ( $sysscoreNW > $max_bvasNW ) { $sysscoreNW = $max_bvasNW }
        if  ( $sysscoreP  > $max_bvasP  ) { $sysscoreP  = $max_bvasP  }
        $bvas_scoreNW += $sysscoreNW;
        $bvas_scoreP  += $sysscoreP;

        push @allresults, @systests;
    }

    # Don't go over the maximum score.
    if  ( $bvas_scoreP  > 33 ) { $bvas_scoreP  = 33 }
    if  ( $bvas_scoreNW > 63 ) { $bvas_scoreNW = 63 }

    # If we've got this far, $bvas_scoreNW and $bvas_scoreP contain the final BVAS.
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

    $c->_set_journal_changeset_attrs();
    $schema->txn_do(
        sub {
            my @bvas;

            # BVAS 1 and 2
            foreach my $testname ( qw( BVAS1 BVAS2 ) ) {
                my $bvastest = $schema->resultset('Test')->find_or_create({ name => $testname });
                my $bvas = $schema->resultset('TestResult')->find_or_new({
                    test_id => $bvastest->id(),
                    date    => $container->date(),
                    %opts,
                });
                push @bvas, $bvas;
            }

            # Actually set the scores.
            unless ( $bvas[0]->value() eq $bvas_scoreNW ) {
                $bvas[0]->set_column( 'value' => $bvas_scoreNW );  # BVAS1
                $bvas[0]->update_or_insert();
            }
            unless ( $bvas[1]->value() eq $bvas_scoreP ) {
                $bvas[1]->set_column( 'value' => $bvas_scoreP );   # BVAS2
                $bvas[1]->update_or_insert();
            }

            # Ensure the child test results are all linked to the BVAS.
            foreach my $n ( 0..$#bvas ) {
                foreach my $child ( @allresults ) {
                    $schema->resultset('TestAggregation')->find_or_create({
                        test_result_id      => $child->id(),
                        aggregate_result_id => $bvas[$n]->id(),
                    });
                }
            }
        }
    );

    return $is_valid;
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;
