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

use Data::Dumper;

sub parse_args {

    my ( $mapfile, $want_help );

    GetOptions(
        "m|mapfile=s" => \$mapfile,
        "h|help"      => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $mapfile && scalar @ARGV ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( $mapfile, \@ARGV );
}

sub parse_mapfile {

    my ( $mapfile ) = @_;

    
}

my ( $mapfile, $dirs ) = parse_args();




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

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
