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

use Getopt::Long;
use List::Util qw(first);

use CIMR::AccessImporter qw(import_schema import_data);

########
# SUBS #
########

sub parse_args {

    my ( $db_file, $out_file, $command, $want_help );

    GetOptions(
        "d|database=s" => \$db_file,
        "o|output=s"   => \$out_file,
        "c|command=s"  => \$command,
        "h|help"       => \$want_help,
    );

    if ( $want_help || ! ( $command && $db_file && $out_file ) ) {

        print (<<"USAGE");

    Usage: $0 -d <mdb file> -c <command> -o <output SQLite DB file>

       where <command> is one of: schema data full

USAGE

        exit 255;
    }
    
    $command = lc $command;

    unless ( first { $_ eq $command } qw( full schema data ) ) {
        die("Error: unrecognised command. Use the -h option for usage info.\n")
    }

    return ( $db_file, $out_file, $command );
}

########
# MAIN #
########

my ( $db_file, $out_file, $command ) = parse_args();

# Import the schema.
if ( $command eq 'schema' || $command eq 'full' ) {
    import_schema( $db_file, $out_file );
}

# Import the data.
if ( $command eq 'data' || $command eq 'full' ) {
    import_data( $db_file, $out_file );
}


