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
# Quicky script to remove all the TestResults specified in the
# blood_import_mapping.yml file from a ClinStudyML document. Useful
# when rebuilding the database from scratch (hopefully not often).

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

use Data::Dumper;
use XML::LibXML;
use Config::YAML;

sub parse_args {

    my ( $xml, $mapfile, $want_help );

    GetOptions(
        "m|mapping=s" => \$mapfile,
        "x|xml=s"     => \$xml,
        "h|help"      => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $xml && $mapfile ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($xml);

    my $mapping  = Config::YAML->new(config => $mapfile);
    my @unwanted = keys %{ $mapping->get_import_mapping() };

    return( $doc, \@unwanted );
}

my ( $doc, $unwanted ) = parse_args();

foreach my $test ( @$unwanted ) {
    warn("Stripping out $test results...\n");
    my @nodes = $doc->findnodes(qq{.//TestResult[\@test="$test"]});
    foreach my $node ( @nodes ) {
        $node->unbindNode();
    }
}

print $doc->toString(1);

__END__

=head1 NAME

strip_blood_data.pl

=head1 SYNOPSIS

 strip_blood_data.pl -m <import mapping file> -x <ClinStudyML file>

=head1 DESCRIPTION

Strip out all the test results which have been imported via the
import_blood_data.pl mechanism. Strictly speaking, this script strips
out all test results named as if they have been imported using this
script, based on the import mapping config file.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
