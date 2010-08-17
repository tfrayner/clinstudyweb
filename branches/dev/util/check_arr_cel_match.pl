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
# Quick script to look at the CEL files and ARR files in a directory
# and report on any mismatches.

use strict;
use warnings;

use CIMR::Parser::ARR;

opendir( my $dir, '.' )
    or die("Error: unable to open working directory for reading: $!");

my @files = grep { $_ !~ /^\./ } readdir($dir);
my @cels  = grep { /\.CEL$/i } @files;
my @arrs  = grep { /\.ARR$/i } @files;

my %cel_has_arr = map { $_ => undef } @cels;
my %arr_has_cel = map { $_ => undef } @arrs;

foreach my $arrfile ( @arrs ) {

    warn("Checking $arrfile...\n");
    my $arr = CIMR::Parser::ARR->new(arr_file => $arrfile);

    if ( -f $arr->cel_file ) {
        $arr_has_cel{$arrfile} = 1;
        $cel_has_arr{$arr->cel_file} = 1;
    }
}

my @unmatched_cels = grep { ! $cel_has_arr{$_} } @cels;
my @unmatched_arrs = grep { ! $arr_has_cel{$_} } @arrs;

if ( @unmatched_cels ) {
    print ("\nUnmatched CEL files: \n", join("\n", @unmatched_cels), "\n");
}

if ( @unmatched_arrs ) {
    print ("\nUnmatched ARR files: \n", join("\n", @unmatched_arrs), "\n");
}

if ( ! ( @unmatched_arrs | @unmatched_cels ) ) {
    print ("\nAll ARR and CEL files match up. Yay!\n");
}
