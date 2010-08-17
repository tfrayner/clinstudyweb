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
# Script to test the visit dates against the trial ids in the MEDIANTE
# assay spreadsheet. Not used in ages, this is probably obsolete.

use strict;
use warnings;

use ClinStudy::ORM;
use Config::YAML;
use Text::CSV_XS;
use Getopt::Long;

my ( $conffile, $file );

warn("WARNING: this script is probably obsolete!\n");

GetOptions(
    "c|conffile=s" => \$conffile,
    "f|file=s"     => \$file,
);

die("Bad options") unless ( $conffile && $file );

my $config = Config::YAML->new( config => $conffile );
my $connect_info = $config->{'Model::DB'}->{'connect_info'};
my $schema = ClinStudy::ORM->connect( @$connect_info );

open( my $fh, '<', $file ) or die($!);

my $csv = Text::CSV_XS->new({ eol => "\n", sep_char=> "\t"});

LINE:
while ( my $larry = $csv->getline( $fh ) ) {
    my ( $p_id, $v_date ) = @{ $larry }[10,9];
    next LINE unless ( $p_id );
    my $patient = $schema->resultset('Patient')->find({
        trial_id => $p_id,
    });
    unless ( $patient ) {
        warn("WARNING: Patient $p_id not found.\n");
        next LINE;
    }
    next LINE unless ( $v_date );
    my $visit = $schema->resultset('Visit')->find({
        patient_id => $patient->id(),
        date => $v_date,
    });
    unless ( $visit ) {
        warn("WARNING: Visit for patient $p_id on $v_date not found.\n");
        next LINE;
    }
}
