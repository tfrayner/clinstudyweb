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
use ClinStudy::ORM;
use ClinStudy::XML::Loader;
use ClinStudy::XML::AdminLoader;
use ClinStudy::XML::SemanticValidator;

sub parse_args {

    my ( $conffile, $xml, $xsd, $relaxed, $want_help );

    GetOptions(
        "c|config=s"        => \$conffile,
        "x|xml=s"           => \$xml,
        "d|schema=s"        => \$xsd,
        "r|relaxed"         => \$relaxed,
        "h|help"            => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $xsd && $xml ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $config = Config::YAML->new(config => $conffile);
    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($xml);

    return( $config->{'Model::DB'}->{connect_info}, $xsd, $doc, $relaxed, $xml );
}

my ( $conn_params, $xsd, $xml, $relaxed, $xmlfile ) = parse_args();

my $schema = ClinStudy::ORM->connect( @$conn_params );

my $root = $xml->getDocumentElement();
my $loader_class = $root->nodeName() eq 'ClinStudyML'      ? 'ClinStudy::XML::Loader'
                 : $root->nodeName() eq 'ClinStudyAdminML' ? 'ClinStudy::XML::AdminLoader'
                 : die("Error: Unrecognised XML format.\n");

if ( $loader_class eq 'ClinStudy::XML::Loader' ) {
    my $validator = ClinStudy::XML::SemanticValidator->new(
        database    => $schema,
        schema_file => $xsd,
    );
    $validator->check_semantics( $xml )
        or die("Semantic validation failed: \n\n" . $validator->report());
}

my $loader = $loader_class->new(
    database    => $schema,
    schema_file => $xsd,
    is_strict   => ! $relaxed,
);

$schema->changeset_session( $xmlfile );
$schema->txn_do( sub { $loader->load( $xml ); } );

__END__

=head1 NAME

clinstudy_import.pl

=head1 SYNOPSIS

 clinstudy_import.pl -x <XML file> -c <config file> -d <XML schema doc>

=head1 DESCRIPTION

Script to import information in a ClinStudy XML document into a
ClinStudyDB database instance.

=head2 OPTIONS

=over 2

=item -x

The XML to be imported.

=item -c

The main ClinStudyWeb configuration file, containing database
connection parameters.

=item -d

The XML Schema file to use for post-export validation.

=item -r

Tells the script not to validate the XML document against the schema
prior to import. For obvious reasons, this option is NOT RECOMMENDED
unless you really, really know what you're doing. Loading invalid
ClinStudyML into the database may result in partial or broken database
loads which are likely to be time-consuming to clean up. You have been
warned.

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
