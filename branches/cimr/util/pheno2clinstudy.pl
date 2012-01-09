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
use Pod::Usage;
use XML::LibXML;

use ClinStudy::XML::PhenoData;
use ClinStudy::XML::Spreadsheet;

########
# SUBS #
########

sub parse_args {

    my ( $spreadsheet, $xsd, $relaxed, $want_help );

    GetOptions(
        "f|file=s"   => \$spreadsheet,
        "d|schema=s" => \$xsd,
        "r|relaxed"  => \$relaxed,
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $spreadsheet && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( $spreadsheet, $xsd, $relaxed );
}

########
# MAIN #
########

my ( $spreadsheet, $xsd, $relaxed ) = parse_args();

my $parser  = ClinStudy::XML::Spreadsheet->new(
    file => $spreadsheet,
);

my $builder = ClinStudy::XML::PhenoData->new(
    schema_file  => $xsd,
    spreadsheet  => $parser,
    is_strict    => ! $relaxed,
);

$builder->read();

$builder->dump();

__END__

=head1 NAME

pheno2clinstudy.pl

=head1 SYNOPSIS

 pheno2clinstudy.pl -f <spreadsheet file> -d <XML Schema file>

=head1 DESCRIPTION

This script generates ClinStudyML from an input spreadsheet containing
relatively free-form headings. Only three headings are absolutely
required: "Patient|trial_id", "Patient|entry_date", and
"Visit|date". All other headings are assumed to refer to
immunophenotyping results, and the corresponding columns MUST CONTAIN
ONLY NUMERIC DATA (this is currently a constraint of the database).

=head2 OPTIONS

=over 2

=item -f

The spreadsheet file to convert into XML.

=item -d

The XML Schema document against which to validate.

=item -r

Flag indicating that the script should run in relaxed mode, i.e. the
generated XML does not need to be valid (although it must still be
well-formed).

=item -h

Generates this help text.

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
