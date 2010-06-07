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
#
# Script to recalculate all aggregate test results in the database.

use strict;
use warnings;

use Module::Find;
use Getopt::Long;
use ClinStudy::ORM;
use Config::YAML;
use List::Util qw( first );
use Carp;

my ( $conffile );

GetOptions(
    "c|config=s" => \$conffile,
);

unless ( $conffile && -r $conffile ) {
    print <<"USAGE";

Usage: $0 -c <config file>

  The config file should be the main file used with your ClinStudy::Web installation.

USAGE

    exit 255;
}

my $conf = Config::YAML->new( config => $conffile );
my $connect_info = $conf->{'Model::DB'}->{connect_info};
my $schema = ClinStudy::ORM->connect( @$connect_info );

# Load all the test calculator classes.
my @testcalcs = usesub ClinStudy::Web::TestCalc;

foreach my $cont_class ( qw( Visit Hospitalisation ) ) {
    my $rs = $schema->resultset($cont_class)->search();

    while ( my $container = $rs->next() ) {
        my @studies = $container->patient_id()->studies();
        foreach my $study_type ( map { $_->type_id() } @studies ) {
            if ( my $calcname
                     = $conf->{test_calculators}->{ $study_type->value() } ) {
                my $calcclass = "ClinStudy::Web::TestCalc::$calcname";
                unless ( first { $_ eq $calcclass } @testcalcs ) {
                    confess("Error: $calcclass not found in TestCalc module directory.");
                }
                my $calc = $calcclass->new();
                printf ("%s %s: %s ", $cont_class, $container->id, $calcname);
                my $rc;
                eval { $rc = $calc->calculate( $container, $schema ) };
                if ( $@ ) {
                    printf("Error reported by test calculator for %s date %s patient no. %s: %s\n",
                           $cont_class,
                           $container->date(),
                           $container->patient_id()->trial_id(),
                           $@,);
                }
                elsif ( $rc ) {
                    print("okay\n");
                }
                else {
                    print("not calculated\n");
                }
            }
        }
    }
}

