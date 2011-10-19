#!/usr/bin/env perl
#
# Copyright 2011 Tim Rayner, University of Cambridge
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
use Pod::Usage;
use Text::CSV_XS;
use Digest::MD5;
use File::Spec;
use File::Copy;

sub parse_args {

    my ( $mapfile, $want_help, $targetdir, $dryrun );

    GetOptions(
        "m|mapfile=s"   => \$mapfile,
        "d|targetdir=s" => \$targetdir,
        "dry-run"       => \$dryrun,
        "h|help"        => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $mapfile && $targetdir && scalar @ARGV ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( $mapfile, $targetdir, \@ARGV, $dryrun );
}

sub parse_mapfile {

    my ( $mapfile ) = @_;

    open( my $fh, '<', $mapfile )
        or die("Unable to open map file $mapfile: $!\n");

    my $csv = Text::CSV_XS->new({
        sep_char  => "\t",
        eol       => "\n",
    }) or die("Unable to initialise CSV parser.");

    my ( $headstr, $header );
    until ( $headstr && $headstr !~ /^\s*#/ ) {
        $header = $csv->getline($fh);
        unless ( $header && ref $header eq 'ARRAY' ) {
            die("Unable to read file header line.\n");
        }
        $headstr = join('', @$header);
    }

    # Strip whitespace on either side of each column header.
    $header = [ map { s/ \A \s* (.*?) \s* \z /$1/ixms; $_ } @$header ];

    my %map;

    LINE:
    while ( my $line = $csv->getline($fh) ) {
        
        my $str = join('', @$line);
        next LINE if $str =~ /^\s*#/;
        
        my %col;
        @col{@$header} = @$line;

        $map{ $col{'label'} } = {
            triad  => $col{'triad'},
            vdate  => $col{'vdate'},
        };
    }

    # Check that parsing completed successfully.
    my ( $error, $mess ) = $csv->error_diag();
    unless ( $error == 2012 ) {    # 2012 is the Text::CSV_XS EOF code.
        die(
            sprintf(
                "Error in tab-delimited format: %s. Bad input was:\n\n%s\n",
                $mess,
                $csv->error_input(),
            ),
        );
    }

    return \%map;
}

sub md5_file_digest {

    my ( $file ) = @_;

    open ( my $fh, '<', $file )
        or die("Unable to open FACS file $file: $!\n");

    my $md5 = Digest::MD5->new();
    my $chunk;
    my $chunksize = 65536;    # 64k for reasonable efficiency (untested though).
    while ( my $bytes = read( $fh, $chunk, $chunksize ) ) {
	$md5->add( $chunk );
    }

    return $md5->hexdigest();
}

sub make_filename {

    my ( $vhash, $ctype_cv, $file_type, $md5 ) = @_;

    my $filename = join("_", $vhash->{'triad'}, $vhash->{'vdate'});
    $filename =~ s/[^[:alnum:]_]//g;
    $filename .= "_" . $ctype_cv if ( $ctype_cv ne q{} );
    $filename .= "_" . join("_", $file_type, $md5) . ".fcs";

    return $filename;
}

sub process_file {

    my ( $file, $vhash ) = @_;

    my ( $ctype_cv, $file_type );
    if ( $file =~ /^unstained\b/i ) {
        $file_type = 'Unstained';
        $ctype_cv  = q{};
    }
    else {
        ( $ctype_cv, $file_type ) = ( $file =~ /^(\w+) +([^.]+)/ );
        unless ( defined $ctype_cv && defined $file_type ) {
            die("Unable to parse cell and file type from filename: $file\n");
        }
        unless ( $ctype_cv =~ /^CD\d+(?:[ABCD])?$/i || $ctype_cv eq q{} ) {
            die("Unusual cell type found: $ctype_cv");
        }
        $file_type = lc $file_type;
    }

    $ctype_cv = uc($ctype_cv);

    my $ftype_cv;
    if ( $file_type eq 'pre' ) {
        $ftype_cv = 'FACS pre';
    }
    elsif ( $file_type eq '+ve' || $file_type eq 'pos' ) {
        $ftype_cv = 'FACS positive';
    }
    elsif ( $file_type eq 'Unstained' ) {
        $ftype_cv = 'FACS unstained';
    }
    elsif ( $file_type eq 'flow' || $file_type eq 'neg' ) {
        return;
    }
    else {
        die("Unrecognised file type: $file_type\n");
    }

    my $md5 = md5_file_digest( $file );

    my $newfile = make_filename( $vhash, $ctype_cv, $file_type, $md5 );

    return( $newfile, $ctype_cv, $ftype_cv );
}

sub process_directory {

    my ( $dir, $targetdir, $vhash, $dryrun ) = @_;

    # N.B. $targetdir must be an absolute path.

    opendir( my $dh, $dir )
        or die("Cannot open directory $dir: $!\n");

    my @files = grep { /^[^.]/ && -f "$dir/$_" } readdir($dh);
    closedir $dh;

    warn("Entering directory $dir...\n");

    chdir($dir) or die("Cannot change directory to $dir:$!\n");

    FILE:
    foreach my $file ( @files ) {

        # Allow for junk directories.
        next FILE if ( $file eq 'junk' && -d $file );

        my ( $md5file, $celltype, $filetype )
            = process_file( $file, $vhash );

        # Copy the $file to $md5file in a target directory.
        if ( defined $md5file ) {
            warn("Copying file to $md5file...\n");

            unless ( $dryrun ) {
                copy( $file, File::Spec->catfile( $targetdir, $md5file ) )
                    or die("Unable to copy FACS data file $file to target directory: $!");
            }

            if ( $filetype eq 'FACS unstained' ) {
                print STDOUT (join("\t",
                                   q{}, q{},
                                   $celltype,
                                   q{},
                                   $vhash->{'triad'},
                                   $md5file,
                                   $filetype,
                                   $vhash->{'vdate'}), "\n")
            }
            else {
                print STDOUT (join("\t",
                                   $md5file,
                                   $filetype,
                                   $celltype,
                                   'RNA',
                                   $vhash->{'triad'},
                                   q{}, q{},
                                   $vhash->{'vdate'}), "\n")
            }
        }
    }

    chdir('..') or die("Cannot exit directory $dir:$!\n");

}

########
# MAIN #
########

my ( $mapfile, $targetdir, $dirs, $dryrun ) = parse_args();

my $map = parse_mapfile( $mapfile );

$targetdir = File::Spec->rel2abs( $targetdir );

unless ( -d $targetdir || $dryrun ) {
    mkdir $targetdir;
}

# Quick pre-check that all the directories on the command line can be
# mapped to patient visits.
my %not_found;
foreach my $dir ( @$dirs ) {
    $not_found{$dir}++ unless ( exists $map->{ $dir } );
}
if ( scalar grep { defined $_ } values %not_found ) {
    die(join("\n",
             "Directories not found in the map file: ", keys %not_found));
}

print STDOUT (join("\t",
                   'SampleDataFile|filename',
                   'SampleDataFile|type',
                   'Sample|cell_type',
                   'Sample|material_type',
                   'Patient|trial_id',
                   'VisitDataFile|filename',
                   'VisitDataFile|type',
                   'Visit|date'), "\n");

foreach my $dir ( @$dirs ) {
    process_directory( $dir, $targetdir, $map->{ $dir }, $dryrun );
}

__END__

=head1 NAME

facs_clinstudyml.pl

=head1 SYNOPSIS

 facs_clinstudyml.pl -m <mapfile> <list of FACS directories>

=head1 DESCRIPTION

Given a list of directories containing purity FACS data, and a mapping
file which must contain the columns documented below, this script will
attempt to create a tab-delimited output file suitable for use with
reannotate_tab.pl and tab2clinstudy.pl. The files found will be
renamed with a unique ID based on an md5 hash of their contents and
annotated appropriately with patient, visit, cell type and sample data
type entries. The reannotate_tab.pl script should then be able to pull
out additional required annotation from your ClinStudyWeb database so
that tab2clinstudy.pl can build a valid ClinStudyML document.

This script relies on our local CIMR conventions for FACS purity data
and implements some conventions of its own. It is not designed for
general use.

=head1 MAPPING FILE

The following column headings are required:

=over 4

=item label

The name of the FACS data directory. All of the directories specified
on the command line must be represented in this column.

=item triad

The Patient TRIAD ID.

=item vdate

The Visit date.

=back

=head1 OPTIONS

=head2 -m

The name of the mapping file.

=head2 -h

Prints this help text.

=head2 --dry-run

Make no changes to the filesystem.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
