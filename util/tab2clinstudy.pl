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

use ClinStudy::XML::TabReader;

########
# SUBS #
########

sub parse_args {

    my ( $tabfile, $xsd, $drug_parent, $xmldoc, $relaxed, $want_help );

    GetOptions(
        "f|file=s"   => \$tabfile,
        "r|relaxed"  => \$relaxed,
        "d|schema=s" => \$xsd,
        "x|xml=s"    => \$xmldoc,
        "p|drug-parent=s" => \$drug_parent,
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $tabfile && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    $drug_parent ||= 'Visit';

    my $xml;
    if ( $xmldoc ) {
        my $parser = XML::LibXML->new();
        $xml       = $parser->parse_file($xmldoc);
    }

    return( $tabfile, $xsd, $relaxed, $drug_parent, $xml );
}

########
# MAIN #
########

my ( $tabfile, $xsd, $relaxed, $drug_parent, $xml ) = parse_args();

my %build_opts = (
    schema_file  => $xsd,
    is_strict    => ! $relaxed,
    drug_parent  => $drug_parent,
    tabfile      => $tabfile,
);
$build_opts{root} = $xml->getDocumentElement() if ( $xml );
my $builder = ClinStudy::XML::TabReader->new(%build_opts);

$builder->read();

$builder->dump();

__END__

=head1 NAME

tab2clinstudy.pl

=head1 SYNOPSIS

 tab2clinstudy.pl -f <tab-delimited file> -d <XML Schema file>

=head1 DESCRIPTION

This script generates ClinStudyML from an input tab-delimited
file. The file headings must be of the form "Element|attribute", for
example "Patient|entry_date".

=head2 OPTIONS

=over 2

=item -f

The tab-delimited file to convert into XML.

=item -d

The XML Schema document against which to validate.

=item -x

An optional argument specifying a pre-existing XML document which
should be updated with the new data.

=item -r

Flag indicating that the script should run in relaxed mode, i.e. the
generated XML does not need to be valid (although it must still be
well-formed).

=item -p

Drugs can in principle be attached to either Visit or
PriorTreatment. Only one parent class can be supported per run of this
script. By default we attempt to attach everything to Visit, but this
option allows the user to redirect the attachment if necessary.

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
