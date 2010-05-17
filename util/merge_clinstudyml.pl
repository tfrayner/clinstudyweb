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

use ClinStudy::ORM;
use ClinStudy::XML::Loader;
use ClinStudy::XML::Dumper;

sub parse_args {

    my ( $want_help, $xsd, $relaxed );

    GetOptions(
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

    unless ( @ARGV && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( \@ARGV, $xsd, $relaxed );
}

my ( $files, $xsd, $relaxed ) = parse_args();

use DBICx::Deploy;
use File::Temp qw(tempfile);

# The trick here is to use a temporary SQLite database with our
# standard XML Loader and Dumper classes.
my ( undef, $tmpfile ) = tempfile( OPEN => 0 );
my $dsn = "dbi:SQLite:$tmpfile";

# FIXME now that CV accession is required this doesn't really work -
# either we need a way to import the semantic framework alongside the
# merged data, or we need to be able to deactivate the CV accession
# requirement.
DBICx::Deploy->deploy('ClinStudy::ORM' => $dsn);
my $schema = ClinStudy::ORM->connect( $dsn );

my $loader = ClinStudy::XML::Loader->new(
    database    => $schema,
    schema_file => $xsd,
    is_strict   => !$relaxed,
    is_constrained => 0,
);

foreach my $file ( @$files ) {
    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($file);
    $loader->load( $doc );
}

my $dumper = ClinStudy::XML::Dumper->new(
    database    => $schema,
    schema_file => $xsd,
    is_strict   => !$relaxed,
);

my $xml = $dumper->xml_all();
print $xml->toString(1);

unlink($tmpfile);

__END__

=head1 NAME

clinstudy_import.pl

=head1 SYNOPSIS

 clinstudy_import.pl -d <XML Schema file> <list of ClinStudyML files>

=head1 DESCRIPTION

Script to merge a set of ClinStudyML documents.

=head2 OPTIONS

=over 2

=item -d

The XML Schema document to use for validation.

=item -r

Tells the script not to validate the XML documents against the schema
prior to merging. For obvious reasons, this option is NOT RECOMMENDED
unless you really, really know what you're doing. Merging invalid
ClinStudyML into the database is likely to result in broken output
documents which will be time-consuming to clean up. You have been
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
