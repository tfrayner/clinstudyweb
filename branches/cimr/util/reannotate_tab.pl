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
use Config::YAML;

use ClinStudy::ORM;
use ClinStudy::XML::TabReannotator;

########
# SUBS #
########

sub parse_args {

    my ( $tabfile, $xsd, $conffile, $want_help );

    GetOptions(
        "f|file=s"   => \$tabfile,
        "c|config=s" => \$conffile,
        "d|schema=s" => \$xsd,
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $tabfile && $xsd && $conffile ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $config = Config::YAML->new(config => $conffile);
    my $conn_params = $config->{'Model::DB'}->{connect_info};
    my $schema = ClinStudy::ORM->connect( @$conn_params );

    return( $tabfile, $xsd, $schema );
}

########
# MAIN #
########

my ( $tabfile, $xsd, $schema ) = parse_args();

my $builder = ClinStudy::XML::TabReannotator->new(
    schema_file  => $xsd,
    tabfile      => $tabfile,
    database     => $schema,
);

$builder->read();

__END__

=head1 NAME

reannotate_tab.pl

=head1 SYNOPSIS

 reannotate_tab.pl -f <tab-delimited file> -d <XML Schema file> -c clinstudy_web.yml

=head1 DESCRIPTION

This script reads a tab-delimited data file, queries a ClinStudy
database to retrieve missing information, and prints out the results
to STDOUT.

=head2 OPTIONS

=over 2

=item -f

The tab-delimited file to convert into XML.

=item -d

The XML Schema document against which to validate.

=item -c

The main clinstudy_web.yml configuration file containing database
connection details.

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
