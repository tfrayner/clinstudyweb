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

use URI;
use Term::ReadKey;

use ClinStudy::MAGETAB::Dumper;

sub parse_args {

    my ( $uri, $conffile, $want_help );

    GetOptions(
        "u|uri=s"           => \$uri,
        "c|config=s"        => \$conffile,
        "h|help"            => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $uri && $conffile && scalar @ARGV ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    $uri = URI->new($uri);

    return( $uri, $conffile, \@ARGV );
}

my ( $uri, $conffile, $filenames ) = parse_args();

# Needs Term::ReadKey to get the user's password securely.
print STDERR ("Username: ");
chomp( my $username = <STDIN> );

ReadMode 2;
print STDERR ("Password: ");
chomp( my $password = <STDIN> );
ReadMode 0;
print STDERR ("\n");

my $dumper = ClinStudy::MAGETAB::Dumper->new(
    uri      => $uri,
    username => $username,
    password => $password,
    config_file => $conffile,
);

foreach my $file ( @$filenames ) {
    $dumper->add_file( $file );
}

$dumper->dump();

__END__

=head1 NAME

clinstudy_magetab.pl

=head1 SYNOPSIS

 clinstudy_magetab.pl -u <ClinStudy web URI> -c <YAML config file> <list of filenames>

=head1 DESCRIPTION

Script to dump information stored in a ClinStudyDB database instance
into a MAGE-TAB document. 

=head2 OPTIONS

=over 2

=item -u

The main URI of the ClinStudy web application (for example, when
running under the Catalyst test server this would be
http://localhost:3000 by default).

=item -c

A configuration file in YAML format containing a MAGETAB section. See
the example clinstudy_web.yml file for details of how this section
should be laid out.

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
