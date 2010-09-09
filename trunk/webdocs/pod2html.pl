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

use 5.8.0;    # Need a recent Pod::HTML, which only comes with newer Perls

use strict;
use warnings;

use Pod::Html;
use File::Spec;

use Getopt::Long;
use File::Find;
use File::Path;
use Cwd;

sub transcode {

    my ( $in ) = @_;

    my $out = '';
    my $i;
    for ( $i = 0; $i < length( $in ); $i++ ) {
        $out .= "&#" . ord(substr($in, $i, 1)) .";";
    }

    return $out;
}

sub mangle_email {

    my ( $html ) = @_;

    open( my $fh, '<', $html )
        or die("Error opening HTML file: $!\n");

    my @lines = <$fh>;
    close( $fh ) or die($!);

    open( my $out, '>', $html )
        or die("Error opening HTML file: $!\n");
    foreach my $line ( @lines ) {

        # Very simplistic email detection.
        if ( my ( $email ) = ( $line =~ m/ \b ( \w+ \@ [\w\.-]+ ) \b /xms ) ) {
            my $mangled = transcode( $email );
            $line =~ s/$email/$mangled/g;
        }
        print $out $line;
    }
}

sub base_wanted {

    my ( $libdir, $cwd, $modules, $pattern ) = @_;

    return unless $File::Find::name =~ m/ $pattern .* \.pm \z/xms;
    
    my $modfile = File::Spec->abs2rel( $File::Find::name, $libdir );
    my $htmldoc = File::Spec->rel2abs( $modfile, $cwd );

    # Replace extension.
    $htmldoc =~ s! \.p[mlh] \z!\.html!ixms;

    my ( $vol, $dir, $name ) = File::Spec->splitpath( $htmldoc );
    mkpath( $dir );

    print "Creating $htmldoc\n";
        
    pod2html(
        "--infile=$File::Find::name",
        "--outfile=$htmldoc",
        "--css=/trunk/webdocs/style.css",
        "--noindex",
        "--htmlroot=/trunk/webdocs/pod",
    );

    system("tidy -m $htmldoc > /dev/null 2>&1");

    mangle_email( $htmldoc );

    my ( $modvol, $moddir, $modname ) = File::Spec->splitpath( $modfile );
    $moddir  =~ s/ [\/\\] \z//xms;
    $modname =~ s/ \.pm \z//xms;
    $modname = join('::', File::Spec->splitdir( $moddir ), $modname);
    push @$modules, [ $modname, File::Spec->abs2rel( $htmldoc, $cwd ) ];
}

sub make_wanted {

    my ( $wanted, @args ) = @_;

    return sub { $wanted->( @args ) };
}

sub generate_html {

    my ( $libdir, $cwd, $pattern ) = @_;

    $libdir = File::Spec->rel2abs( $libdir );
    $libdir = File::Spec->catdir( $libdir, 'lib' );
    unless ( -d $libdir ) {
        die("Error: Cannot find library directory $libdir.");
    }

    my $modules = [];

    my $wanted = make_wanted( \&base_wanted, $libdir, $cwd, $modules, $pattern );

    find( $wanted, $libdir );

    return $modules;
}

my ( $topdir );

GetOptions(
    "d|topdir=s"  => \$topdir,
);

unless ( $topdir && -d $topdir ) {
    print <<"USAGE";
Usage: $0 -d <clinstudyweb root directory>
USAGE

    exit 255;
}

my $cwd = getcwd();

my $modules = generate_html( $topdir, $cwd, qr/ClinStudy/ );

my $idx_file = File::Spec->catfile( $cwd, 'index.html' );
printf ( "Creating %s\n", $idx_file );
open( my $index, '>', $idx_file ) or die("Problems opening index file: $!\n");

print $index <<'HEADER';
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>ClinStudyWeb Perl Module Documentation</title>
    <link rel="stylesheet" href="../style.css" type="text/css" />
    <meta http-equiv="content-type" content="text/html; charset=us-ascii" />
  </head>
  <body>
    <div class="main">

      <h1>ClinStudyWeb Perl Modules</h1>

      <ul>
HEADER

foreach my $mod ( @$modules ) {
    print $index <<"LINK";
      <li><a href="$mod->[1]">$mod->[0]</a></li>
LINK
}

print $index <<'FOOTER';
      </ul>
    </div>
  </body>
</html>
FOOTER

