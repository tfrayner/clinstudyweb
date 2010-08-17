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
# Script to reorganise files based on a set of criteria. We may end up
# pointing this at a database rather than a flat-file.

use strict;
use warnings;

use CIMR::TabFileQuery;

use Getopt::Long;
use File::Find;
use File::Path;
use File::Spec;
use File::Copy;

########
# MAIN #
########

my (
    $source,
    $dest,
    $pattern,
    $heirarchy,
    $annot_file,
    $id_field,
    $want_copy,
    $is_dummy,
    $report_unused,
);

GetOptions(
    "s|source=s"      => \$source,
    "d|destination=s" => \$dest,
    "p|pattern=s"     => \$pattern,
    "h|heirarchy=s"   => \$heirarchy,
    "f|file=s"        => \$annot_file,
    "i|id-field=s"    => \$id_field,
    "c|copy"          => \$want_copy,
    "n|dummy"         => \$is_dummy,
    "u|unused"        => \$report_unused,
);

unless ( $source && $dest && $annot_file ) {

    print <<"USAGE";

    Usage: $0 -s <source dir> -d <destination dir> -f <annotation file>

  Options:

        -i : ID field to use from the annotation file (default: "array").

        -p : regexp pattern to use to filter the target files. This
             must contain a single parenthesized capture which extracts
             the value to use as the ID in queries of the annotation
             file. Note that this regexp will be anchored to the beginning
             and end of the filename, i.e. \$file =~ /\\A \$pattern \\z/xms.

        -h : heirarchy of destination directory, based on the
             column names from the annotation file (default: "cd/disease/cohort").

        -c : copy the files from source to destination, rather than moving them (the default).

        -n : don't make any changes to the filesystem (dummy mode).

        -u : report on all the array IDs not found in the source directory - use with -n option
             to check up on the whole set of files deposited in the target directory.

USAGE

    exit 255;
}

$pattern   ||= '(?:US)?\d+_((?:\w+_)?\d{8}(?:_\w+)?)_S\d+(?:_\w+)?\.tiff?';
$heirarchy ||= 'cd/disease/cohort';
$id_field  ||= 'array';

$pattern = qr/^$pattern$/;

my @queryterms = split /\//, $heirarchy;

open ( my $fh, '<', $annot_file )
    or die( qq{Error: Unable to open annotation file "$annot_file": $!\n} );

my $qobj = CIMR::TabFileQuery->new(
    'fh'         => $fh,
    'queryterms' => \@queryterms,
    'id_field'   => $id_field,
);

# These need to be absolute paths.
$dest   = File::Spec->rel2abs( $dest );
$source = File::Spec->rel2abs( $source );

my %seen;

# This pretty much has to be a closure over $qobj, $pattern et al.
my $wanted = sub {

    # This is correct (File::Find has a bizarre API).
    my $file = $_;

    return if $seen{ $file }++;

    my ( $id ) = ( $file =~ $pattern );
    if ( defined $id ) {

        warn( qq{Processing file "$file"...\n} );

        # Find the annotation for the file, create a directory for it.
        my @dirnames = map { lc($_) } $qobj->query( $id, @queryterms );
        s/[^\w ]//g foreach @dirnames;
        s/ +/_/g    foreach @dirnames;
        unless ( ( scalar grep { defined $_ && $_ ne q{} } @dirnames ) == ( scalar @dirnames ) ) {
            warn( qq{WARNING: One or more query terms is undefined for "$id". Skipping.\n} );
            return;
        }
        unless ( scalar @dirnames ) {
            warn( qq{WARNING: No directory structure returned for "$id". Skipping.\n} );
            return;
        }
        my $newdir = File::Spec->catdir( $dest, @dirnames );
        my $newpath = File::Spec->catfile( $newdir, $file );

        # Actually move or copy the file.
#        $File::Find::name =~ s/ /\\ /g;
        if ( -e $newpath ) {
            warn( qq{Warning: file "$file" already exists. Skipping.\n} );
        }
        elsif ( $is_dummy ) {
            print("mv $File::Find::name $newpath\n");
        }
        else {
            mkpath( $newdir, { verbose => 1 } );
            if ( $want_copy ) {
                copy( $File::Find::name , $newpath )
                    or die(qq{Error: Unable to copy file "$File::Find::name": $!\n});
            }
            else {
                move( $File::Find::name , $newpath )
                    or die(qq{Error: Unable to move file "$File::Find::name": $!\n});
            }
        }
    }

    return;
};

# Do the deed.
find( $wanted, $source );

$qobj->report_unused() if $report_unused;
