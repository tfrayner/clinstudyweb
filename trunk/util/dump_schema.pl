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
use Config::YAML;

package ClinStudy::ORM;

use DBIx::Class::Schema::Loader;

# We use this to load our classes for now.
use base qw(DBIx::Class::Schema::Loader);

__PACKAGE__->loader_options(
#    debug => 1,
);

package main;

my ($dir, $conffile);

GetOptions(
    "d|dir=s"    => \$dir,
    "c|config=s" => \$conffile,
);

unless ( $dir && -d $dir && -w _ && -r _ && $conffile && -r $conffile) {

    print (<<"USAGE");

Error: Either config file or directory not supplied, or not readable/writable.

Usage: $0 -d <directory> -c <config file>

Config file must contain a Model::DB entry (e.g., the main Catalyst site config file).

USAGE

    exit 255;
}

ClinStudy::ORM->dump_to_dir( $dir );

my $config = Config::YAML->new( config => $conffile );

my $connect_info = $config->{'Model::DB'}->{'connect_info'};

# Apparently D::C::S::L won't follow relationships when
# on_connect_call => set_strict_mode is used.
if ( ref $connect_info->[3] eq 'HASH' ) {
    delete $connect_info->[3]->{on_connect_call};
}
my $schema = ClinStudy::ORM->connect( @$connect_info );

