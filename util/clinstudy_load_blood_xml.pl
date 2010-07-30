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

# With apologies for the whimsy.
package SocialServices;

use Moose;
use Date::Calc qw(Date_to_Days);
use List::Util qw(first);

has 'database' => ( is    => 'ro',
                    isa   => 'DBIx::Class::Schema', );

has 'vnotes'   => ( is       => 'ro',
                    isa      => 'Str',
                    required => 1,
                    default  => 'Approximate visit date inferred from test results.');

sub reparent {

    # This is the main entry point.
    my ( $self, $trial_ids ) = @_;

    my $rs;
    if ( $trial_ids && ref $trial_ids eq 'ARRAY' && scalar @$trial_ids ) {
        $rs = $self->database->resultset('Patient')->search( { trial_id => { in => $trial_ids}  } );
    }
    else {
        $rs = $self->database->resultset('Patient');
    }

    while ( my $patient = $rs->next() ) {
        warn(sprintf("Checking test results for patient %s...\n", $patient->trial_id() ));
        $self->_process_patient( $patient );
    }

    # Final run-through to set all tests such that they're no longer
    # wanting reparenting.
    my $tr = $self->database->resultset('TestResult')
                  ->search({ needs_reparenting => { '!=' => undef } });
    $self->database->txn_do(
        sub{
            while ( my $result = $tr->next() ) {
                $result->set_column('needs_reparenting', undef);
                $result->update();
            }
        }
    );

    return;
}

sub _get_filtered_patient_visits {

    my ( $self, $patient ) = @_;

    # Just return those visits which have a test result needing inspection.

    # FIXME there must be a better way; this does however have the
    # advantage of yielding a visit object which will list all its
    # test_results, not just the ones needing reparenting.
    my @visits = $patient->search_related('visits')
                         ->search_related('test_results', { 'needs_reparenting' => { '!=' => undef } } )
                         ->search_related('visit_id', {}, { distinct => 1 });
    
    return \@visits;
}

sub _date_to_days {

    my ( $self, $date ) = @_;

    my ( $y, $m, $d ) = split /-/, $date;
    
    my $days = Date_to_Days( $y, $m, $d );

    return $days;
}

sub _split_visits {

    my ( $self, $patient ) = @_;

    my %visit_date = map { $_->date() => $_ } $patient->visits();

    my $visits = $self->_get_filtered_patient_visits( $patient );

    VISIT:
    foreach my $visit ( @$visits ) {
        my $vdate   = $visit->date();
        my $vdays   = $self->_date_to_days( $vdate );

        my %batch;
        foreach my $result ( $visit->test_results() ) {
            push @{ $batch{ $result->test_id()->name() }{ $result->date() } }, $result;
        }

        TEST:
        while ( my ( $test, $datebatch ) = each %batch ) {

            # Only one batch of test results; we'll just leave them where
            # they are for now.
            next TEST if ( ( scalar grep { defined $_ } values %$datebatch ) == 1 );

            # Figure out which test batch is closest to the visit date,
            # delete that batch from the $datebatch hashref.
            my ( $closest, $score, $days );
            foreach my $date ( keys %$datebatch ) {
                $days = $self->_date_to_days( $date );
                my $diff = $days - $vdays;

                # Really not possible to have a test result which precedes its visit.
                if ( $diff >= 0 && ( ! defined $score || $score > $diff ) ) {
                    $closest = $date;
                    $score   = $diff;
                }
            }

            # We remove the result with the date closest to the date
            # of this visit batch, so we can reparent all the others.
            if ( defined $closest && exists $datebatch->{$closest} ) {
                delete $datebatch->{ $closest };
            }
            else {
                
                # This isn't really a problem.
                warn("No good batch of $test tests found for visit date $vdate.\n");
            }

            # Rehome the rest of the batches.
            while ( my ( $date, $results ) = each %$datebatch ) {

                my $visit;
                $self->database->txn_do(
                    sub {
                        $visit = $self->database->resultset('Visit')->find_or_new({
                            date       => $date,
                            patient_id => $patient->id(),
                        });

                        # Only add a note to visits which don't already have one.
                        unless ( $visit->notes() ) {
                            $visit->set_column('notes', $self->vnotes());
                        }

                        $visit->update_or_insert();
                    }
                );

                foreach my $r ( @$results ) {
                    $self->_rehome_result( $r, $visit );
                }
            }
        }
    }

    return;
}

sub _reduce_visits {

    my ( $self, $patient ) = @_;

    # First, sort the visits.
    my @visits = sort { $a->date() cmp $b->date() } $patient->visits();

    PAIR:
    for ( my $n = 0; $n < scalar @visits - 1; $n++ ) {

        # Check whether the test results between consecutive visits
        # are disjoint sets, and whether the difference in dates is
        # less than a week. If so, rehome the results from the later
        # visit and delete it (if otherwise empty).
        my $v1 = $visits[$n];
        my $v2 = $visits[$n+1];

        # Not interested in rehoming v2 tests if we're already sure of
        # them.
        next PAIR unless $v2->search_related('test_results',
                                             { needs_reparenting =>
                                                   { '!=' => undef } })->count();

        # Check whether the sets of tests overlap at all.
        my @tests1 = map { $_->test_id()->name() } $v1->test_results();
        my @tests2 = map { $_->test_id()->name() } $v2->test_results();

        my $not_disjoint;
        foreach my $test ( @tests1 ) {
            $not_disjoint++ if first { $_ eq $test } @tests2;
        }
        next PAIR if $not_disjoint;

        # Check the time elapsed between the visits
        my $days1 = $self->_date_to_days( $v1->date() );
        my $days2 = $self->_date_to_days( $v2->date() );
        my $diff  = $days2 - $days1;

        # Skip combining visits if they're at least a week apart.
        next PAIR unless ( abs($diff) < 7 );

        # Rehome the results for the second visit to the first.
        foreach my $res ( $v2->test_results() ) {
            $self->_rehome_result( $res, $v1 );
        }

        # Check whether $v2 contains anything worth keeping, and delete it if not.
        my $source  = $v2->result_source();
        my %uninteresting = map { $_ => 1 } $source->primary_columns(), qw(patient_id date);
        my $has_content;

        COLUMN:
        foreach my $col ( $source->columns() ) {

            # Skip columns which must contain values. A visit with
            # just a date is deemed to be uninformative.
            next COLUMN if ( $uninteresting{$col} );
            
            my $value = $v2->get_column($col);

            if ( $col eq 'notes' ) {
                $has_content++ if ( defined $value && $value ne q{} && $value ne $self->vnotes() );
            }
            else {
                $has_content++ if ( defined $value && $value ne q{} );
            }
        }

        # Also increment $n if $v2 is unbound.
        unless ( $has_content ) {
            eval {
                $self->database()->txn_do( sub { $v2->delete() } );
            };
            $n++ unless ( $@ );
        }
        
    }

    return;
}

sub _recheck_visits {

    my ( $self, $patient ) = @_;

    my %visit_date = map { $_->date() => $_ } $patient->visits();

    # For each visit, look at the test results for a given date and
    # determine whether each date set would be better attached to a
    # different visit. Here we just look for exact date matches with a
    # visit that doesn't already have a test result for each given
    # test type.
    foreach my $visit ( @{ $self->_get_filtered_patient_visits( $patient )} ) {

        RESULT:
        foreach my $res ( $visit->test_results() ) {

            next RESULT if ( ! defined $res->needs_reparenting() );

            my $rdate = $res->date();
            if ( my $cand = $visit_date{ $rdate } ) {
                my $rtest = $res->test_id()->name();
                unless ( first { $_->test_id()->name() eq $rtest }
                             $cand->test_results() ) {
                    $self->_rehome_result( $res, $cand );
                }
            }
        }
    }

    return;
}

sub _process_patient {

    my ( $self, $patient ) = @_;

    $self->_split_visits( $patient );

    # Following detailed inspection of the output, a second (and,
    # indeed, third) pass seems to be required here: we want to (a)
    # sort the visits by date, (b) look at consecutive visits to see
    # if they can be merged, and (c) investigate whether any test
    # results could be better homed under a different visit.
    $self->_reduce_visits( $patient );

    $self->_recheck_visits( $patient );

    return;
}

sub _rehome_result {

    my ( $self, $result, $visit ) = @_;

    # We don't really want to rehome test results where
    # needs_reparenting is set to null.
    if ( ! defined $result->needs_reparenting() ) {
        warn("Warning: Not reparenting a previously fixed test result.\n"
           . "  Visit with ID ".$visit->id()." may be missing results from a batch.\n");
        return;
    }

    warn("Rehoming test result: " . $result->date . " to " . $visit->date . "\n");
    $self->database->txn_do(
        sub {
            $result->set_column('visit_id', $visit->id());
            $result->update();
        }
    );

    return;
}

package main;

use Getopt::Long;
use Pod::Usage;
use ClinStudy::ORM;
use Config::YAML;
use XML::LibXML;

use ClinStudy::XML::Loader;

sub fix_reparenting_flag {

    my ( $class, $row_ref ) = @_;

    # Callback used by the import code to fix the needs_reparenting
    # flag on loading.
    if ( $class =~ /::TestResult \z/xms ) {
        $row_ref->{'needs_reparenting'} = 1;
    }

    return $row_ref;
}

sub parse_args {

    my ( $conffile, $xml, $xsd, $relaxed, $want_help );

    GetOptions(
        "c|config=s" => \$conffile,
        "x|xml=s"    => \$xml,
        "d|schema=s" => \$xsd,
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $xsd && $xml ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $config = Config::YAML->new(config => $conffile);

    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($xml);

    return( $config->{'Model::DB'}->{connect_info}, $xsd, $doc, $relaxed, $xml );
}

my ( $conn_params, $xsd, $xml, $relaxed, $xmlfile ) = parse_args();

my $schema = ClinStudy::ORM->connect( @$conn_params );

$schema->changeset_session( $xmlfile );
$schema->txn_do(
    sub {

        my $loader = ClinStudy::XML::Loader->new(
            database    => $schema,
            schema_file => $xsd,
            onload_callback => \&fix_reparenting_flag,
        );

        $loader->load( $xml );

        my @trial_ids = map { $_->getAttribute('trial_id') } $xml->findnodes('.//Patient');

        my $case_worker = SocialServices->new(
            database => $schema,
        );

        $case_worker->reparent( \@trial_ids );
    }
);

__END__

=head1 NAME

clinstudy_load_blood_xml.pl

=head1 SYNOPSIS

 clinstudy_load_blood_xml.pl -c <ClinStudyWeb config file>
                                 -x <XML file> -d <XML schema doc>

=head1 DESCRIPTION

When we import blood test results, the relevant script will try and
match up test results with visit dates. In cases where the test date
is out of range of the visit dates it just attaches the test result to
the nearest date, which can lead to multiple instances of a given test
attached to a visit. We want to avoid this situation so this script
will generate new visits to cover the otherwise orphaned test results,
and rehome those results appropriately.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
