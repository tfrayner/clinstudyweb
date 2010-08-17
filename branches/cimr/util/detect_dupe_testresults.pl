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
# Quicky script to check for TestResults with duplicated dates for a
# given Patient/test name. This is allowed by the database, but
# generally discouraged by local policy.
#
# Doesn't actually fix, but does detect them and report them.

use strict;
use XML::LibXML;

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file(shift);

foreach my $patient ( $doc->findnodes('.//Patients/Patient') ) {
    my $trial_id= $patient->getAttribute('trial_id');
    my %tr;
    foreach my $r ( $patient->findnodes('.//TestResults/TestResult') ) {
        $tr{ $r->getAttribute('test') }{ $r->getAttribute('date') } ++;
    }

    while ( my ( $test, $score ) = each %tr ) {
        foreach my $bad ( grep { $score->{$_} > 1 } keys %$score ) {
            print("Duplicate found for patient $trial_id $test on $bad\n");
        }
    }
}

