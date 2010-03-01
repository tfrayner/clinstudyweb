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
use Config::YAML;
use XML::LibXML;
use ClinStudy::ORM;
use ClinStudy::XML::Schema;
use ClinStudy::XML::Dumper;
use ClinStudy::XML::AdminDumper;

sub get_rootname {

    my ( $xsd ) = @_;

    my $parser = XML::LibXML->new();
    my $sdoc   = $parser->parse_file( $xsd );
    my $root   = $sdoc->getDocumentElement();
    my @elems  = $root->getChildrenByTagName('xs:element');
    unless ( scalar @elems == 1 ) {
        die("Error: Invalid XML Schema document.\n");
    }
    my $rootname = $elems[0]->getAttribute('name');

    return $rootname;
}

sub parse_args {

    my ( $conffile, $trial_id, $batch_name, $xsd, $want_help );

    GetOptions(
        "c|config=s"        => \$conffile,
        "p|patient=s"       => \$trial_id,
        "a|assay-batch=s"   => \$batch_name,
        "d|schema=s"        => \$xsd,
        "h|help"            => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $config = Config::YAML->new(config => $conffile);

    return( $config->{'Model::DB'}->{connect_info}, $xsd, $trial_id, $batch_name );
}

my ( $conn_params, $xsd, $trial_id, $batch_name ) = parse_args();

my $schema = ClinStudy::ORM->connect( @$conn_params );

my $rootname = get_rootname( $xsd );

my $dumper_class = $rootname eq 'ClinStudyAdminML' ? 'ClinStudy::XML::AdminDumper'
                 : $rootname eq 'ClinStudyML'      ? 'ClinStudy::XML::Dumper'
                 : die("Error: Unrecognised XML schema type $rootname.\n");

my $dumper = $dumper_class->new(
    database    => $schema,
    schema_file => $xsd,
);

# FIXME this depends on our command-line options. Individual patient
# or AssayBatch exports are not yet supported.
my $xml = $dumper->xml_all();
print $xml->toString(1);

__END__

=head1 NAME

clinstudy_dump.pl

=head1 SYNOPSIS

 clinstudy_dump.pl -c <config file> -d <XML schema file>

=head1 DESCRIPTION

Script to dump information stored in a ClinStudyDB database instance
to XML complying with the ClinStudyML schema. This script can export
either individual Patient or AssayBatch records, or the entire
contents of the database. The latter behaviour is the default in the
absence of -a or -p options (see below). Export of a single
Patient will also export any associated AssayBatches, and vice versa.

Local user metadata can also be dumped using this script, by replacing
the ClinStudyML schema document with the ClinStudyAdminML document.

=head2 OPTIONS

=over 2

=item -c

The main ClinStudyWeb configuration file, containing database
connection parameters.

=item -d

The XML Schema file to use for post-export validation. Note that this
can be either the ClinStudyML document (for exporting all clinical
data) or the ClinStudyAdminML document (for exporting just the local
user metadata).

=item -p

The trial_id value of the Patient record to export. NOT YET SUPPORTED (FIXME).

=item -a

The name of the AssayBatch to export. NOT YET SUPPORTED (FIXME).

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
