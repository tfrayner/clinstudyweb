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

package MyBuilder;

use ClinStudy::XML::Builder;

use Moose;
extends 'ClinStudy::XML::Builder';

use Date::Calc qw(Decode_Date_US Parse_Date Date_to_Days);

sub find_surrounding_visits {

    my ( $date_days, $visit_days ) = @_;

    my @surrounding_indices;
    for ( my $i = 0; $i < scalar @$visit_days; $i++ ) {
        if ( $visit_days->[$i] <= $date_days ) {
            $surrounding_indices[0] = $i;
        }
        elsif ( ! defined $surrounding_indices[1] ) {
            $surrounding_indices[1] = $i;
        }
    }

    return \@surrounding_indices;
}

sub find_closest_date_index {

    my ( $date_days, $visit_days, $surrounding ) = @_;

    my $diff1 = $date_days - $visit_days->[$surrounding->[0]];
    my $diff2 = $visit_days->[$surrounding->[1]] - $date_days;

    # Take our best guess at exactly which visit a given test should
    # be associated with.
    my $best;
    if ( $diff1 > $diff2 ) {

        # Date is closer to the second visit.
        if ( $diff2 > 3 ) {

            # Dates more than 3 days before second visit get
            # associated with first visit.
            $best = $surrounding->[0];
        }
        else {

            # Date associated with second visit.
            $best = $surrounding->[1];
        }
    }
    else {

        # Date is closer to, and associated with, the first visit.
        $best = $surrounding->[0];
    }
    
    return $best;
}

sub find_nearest_visit_date {

    my ( $dateparts, $visithash ) = @_;

    # Use Date::Calc to figure out the best visit date to attach
    # the result to. Note that the database schema currently
    # constrains visits to one per person per date.

    my $date = sprintf("%04d-%02d-%02d", @$dateparts);

    my @visit_dates = keys %$visithash;

    my @visit_days = map {
        my @parts = ( $_ =~ m!(\d+) - (\d+) - (\d+)!xms );
        die("Unable to parse date $_") unless scalar @parts;
        Date_to_Days(@parts) } @visit_dates;
    my $date_days = Date_to_Days(@$dateparts)
        or die("Error: unable to parse test date $date");

    my $surrounding_indices = find_surrounding_visits(
        $date_days,
        \@visit_days,
    );

    my $best_index;
    if ( (scalar grep { defined $_ } @$surrounding_indices) == 2 ) {

        # Start date and end date found. Identify the closest:
        $best_index = find_closest_date_index(
            $date_days,
            \@visit_days,
            $surrounding_indices,
        );
    }
    elsif ( defined $surrounding_indices->[0] ) {

        # Only the start date found.
        $best_index = $surrounding_indices->[0];
        warn("Warning: Test result on $date is being associated"
           . " with LAST visit date $visit_dates[$best_index].\n");
    }
    elsif ( defined $surrounding_indices->[1] ) {

        # Only the end date found.
        $best_index = $surrounding_indices->[1];
        warn("Warning: Test result on $date is being associated"
           . " with FIRST visit date $visit_dates[$best_index].\n");
    }
    else {

        # No dates found. Probably no visits available for this patient.
        die("Error: unable to find a visit window for result date $date.\n");
    }

    my $bestdate = $visit_dates[ $best_index ];

    my $db_visit = $visithash->{$bestdate};

    return $db_visit;
}

sub get_visit_for_test {

    my ( $self, $usdate, $hosp_no, $testname, $result, $main_schema ) = @_;

    my @dateparts = Decode_Date_US( $usdate );
    unless ( scalar @dateparts ) {
        die("Error: unable to parse US date $usdate\n");
    }

    # Retrieve the corresponding Visit from $main_schema. Note that
    # there will be many unknown patients in the input, which we can't
    # do much about.

    # N.B. due to anonymity concerns we are now mapping the data
    # through study identifier, rather than hospital number.
    my $db_patient = $main_schema->resultset('Patient')->find({
        trial_id => $hosp_no,
    });
    unless ( $db_patient ) {
        warn("WARNING: Unknown Hospital Number $hosp_no. Skipping this entry.\n");
        return;
    }

    # Find any preexisting tests for this patient with the same test date...
    my $db_visit;
    my $db_test = $main_schema->resultset('Test')->find({
        name => $testname,
    }) or die("Error: No Test found with name $testname");
    my $date = sprintf("%04d-%02d-%02d", @dateparts);
    my @preexisting = $db_patient->search_related('visits')
                                 ->search_related('test_results',
                                                  { 'test_results.date'    => $date,
                                                    'test_results.test_id' => $db_test->id() });
    if ( scalar @preexisting == 1 ) {
        my $value = $preexisting[0]->value();
        if ( ! defined($value) ) {
            $value = $preexisting[0]->controlled_value_id()
                   ? $preexisting[0]->controlled_value_id()->value()
                   : undef;
        }

        # $result in DB is VARCHAR so we use ne, case insensitive.
        if ( ! defined($value) || lc($value) ne lc($result) ) {  
            warn("Note: Pre-existing test result will be updated...\n");
            $db_visit = $preexisting[0]->visit_id();
        }
        else {
            warn("Note: Skipping pre-existing test result...\n");
            return;
        }
    }
    elsif ( scalar @preexisting > 1 ) {
        die(sprintf("Error: Multiple tests found for patient %s on date %s\n",
                    $db_patient->trial_id(),
                    $date));
    }

    # If no pre-existing test found, find the closest visit date match we can.
    unless ( $db_visit ) {

        # Key our visit dates by number of days for comparison to the test date.
        my %visit = map { $_->date() => $_ } $db_patient->visits();

        $db_visit = find_nearest_visit_date( \@dateparts, \%visit );

        unless ( $db_visit ) {
            die(qq{Error: Unable to find suitable visit date for $usdate.});
        }
    }
    
    return ($db_visit, $date);
}

package main;

use Getopt::Long;
use Pod::Usage;
use ClinStudy::ORM;
use CIMR::BloodDB;
use Config::YAML;

sub camel_case {

    my ( $term ) = @_;

    # Taken from DBIx::Class::Schema::Loader::Base for (hopefully) a
    # measure of consistency.
    my $camel = join '', map { ucfirst $_ } split /[\W_]+/, lc $term;

    return $camel;
}


sub parse_args {

    my ( $conffile, $blood_db, $mapfile, $xsd, $relaxed, $want_help );

    GetOptions(
        "c|config=s"   => \$conffile,
        "m|mapping=s"  => \$mapfile,
        "b|blood-db=s" => \$blood_db,
        "d|schema=s"   => \$xsd,
        "r|relaxed"    => \$relaxed,
        "h|help"       => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $blood_db && $mapfile && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( $conffile, $blood_db, $mapfile, $xsd, $relaxed );
}

my ( $conffile, $blood_db, $mapfile, $xsd, $relaxed ) = parse_args();


# Connect to the two databases.
my $config  = Config::YAML->new(config => $conffile);
my $mapping = Config::YAML->new(config => $mapfile);
my $connect_info = $config->{'Model::DB'}->{'connect_info'};
my $main_schema = ClinStudy::ORM->connect( @$connect_info );

my $blood_schema = CIMR::BloodDB->connect(
    sprintf("dbi:SQLite:dbname=%s", $blood_db ),
);

# Convert the import mapping into a more useful structure, where
# attributes are sorted by source table and lower- or camel-cased so
# they can be used directly with CIMR::BloodDB.
my %import_table;
while ( my ( $testname, $source ) = each %{ $mapping->get_import_mapping() } ) {
    my $column = lc( $source->{'attr'} );
    my $table  = camel_case( $source->{'table'} );
    $import_table{ $table }{ $column } = $testname;
}

my $builder = MyBuilder->new(
    schema_file => $xsd,
    is_strict   => ! $relaxed,
);

# Loop over each source table.
foreach my $table ( keys %import_table ) {

    # Examine all records; we will delete all the records from the
    # source tables between imports (the imported Table_IDs are not
    # globally unique in any case).
    my $record_rs = $blood_schema->resultset( $table );

    # FIXME occasionally the data contains multiple results for a
    # given test for the same date (at differing times). Presumably we
    # should detect this and use the later result.
    RECORD:
    while ( my $record = $record_rs->next() ) {

        # Set to -1 if deleted, I believe.
        next RECORD if ( $record->can('DeletedYN') && $record->DeletedYN() );

        # Figure out the date and time, convert into a standard form.
        my ( $usdate ) = ( $record->resdate() =~ m! (\d+ / \d+ / \d+) !xms );
        my   $hosp_no  =   $record->hospno();
        my ( $time )   = ( $record->restime() =~ m! (\d+ : \d+ : \d+) !xms );

        TEST:
        foreach my $column ( keys %{ $import_table{ $table } } ) {

            my $testname = $import_table{ $table }{ $column };

            my $result = $record->$column;
        
            if ( defined $result ) {

                my ( $db_visit, $testdate ) = $builder->get_visit_for_test(
                    $usdate, $hosp_no, $testname, $result, $main_schema,
                );
                next TEST unless $db_visit;
                my $visitdate     = $db_visit->date();

                my $patient = $builder->update_or_create_element(
                    'Patient',
                    { trial_id   => $db_visit->patient_id->trial_id(),
                      entry_date => $db_visit->patient_id->entry_date() } );
                
                my $visit = $builder->update_or_create_element(
                    'Visit',
                    { date => $visitdate },
                    $patient );

                # Add a $testname TestResult to Visit.
                $builder->update_or_create_element(
                    'TestResult',
                    { date  => $testdate,
                      test  => $testname,
                      value => $result },
                    $visit );
            }
        }
    }
}

$builder->dump();

__END__

=head1 NAME

import_blood_data.pl

=head1 SYNOPSIS

 import_blood_data.pl -b <blood SQLite database file> -m <mapping file> \
                      -c <config file> -d <XML schema file>

=head1 DESCRIPTION

Script to convert the data held in a SQLite bloods database into ClinStudyML.

=head2 OPTIONS

=over 2

=item -b

SQLite database file to convert.

=item -m

Mapping file; this is a YAML file giving the table relationships to
use to define each test result. See blood_import_mapping.yml for an
example.

=item -c

Main ClinStudyWeb config file.

=item -d

The XML Schema file to use for output validation.

=back

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
