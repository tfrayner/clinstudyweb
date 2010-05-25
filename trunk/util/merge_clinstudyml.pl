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

package MyBuilder;

use Moose;
use ClinStudy::XML::Builder;

extends 'ClinStudy::XML::Builder';

sub merge {

    my ( $self, $doc ) = @_;

    my $root = $doc->getDocumentElement();

    foreach my $group ( $root->getChildrenByTagName('*') ) {
        $self->_merge_group( $group, $self->root() );
    }

    return;
}

sub _merge_group {

    my ( $self, $group, $parent ) = @_;

    foreach my $elem ( $group->getChildrenByTagName('*') ) {
        $self->_merge_element( $elem, $parent );
    }
}

sub _merge_element {

    my ( $self, $elem, $parent ) = @_;

    # FIXME extract the $attrs from $elem.
    my %attr = map { $_->nodeName => $_->getValue } $elem->attributes();

    my $new = $self->update_or_create_element( $elem->nodeName, \%attr, $parent );

    foreach my $group ( $elem->getChildrenByTagName('*') ) {
        $self->_merge_group( $group, $new );
    }
}

package main;

use Getopt::Long;
use Pod::Usage;

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

my $builder = MyBuilder->new(
    schema_file => $xsd,
);

foreach my $file ( @$files ) {
    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($file);
    $builder->merge( $doc );
}

print $builder->dump();


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
