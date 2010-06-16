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

package ClinStudy::MAGETAB::Dumper;

use 5.008;

use strict; 
use warnings;

use Moose;

use Bio::MAGETAB;
use Bio::MAGETAB::Util::Writer;
use URI;

use Carp;
use Data::Dumper;

our $VERSION = '0.01';

has 'uri'      => ( is       => 'ro',
                    isa      => 'URI',
                    required => 1, );

has 'username' => ( is       => 'ro',
                    isa      => 'Str',
                    required => 1, );

has 'password' => ( is       => 'ro',
                    isa      => 'Str',
                    required => 1, );

has 'magetab' => ( is       => 'ro',
                   isa      => 'Bio::MAGETAB',
                   required => 1,
                   default  => sub { Bio::MAGETAB->new() }, );

sub dump {

    my ( $self ) = @_;

    # Sort objects into SDRFRows FIXME.

    # Write out all objects.
    my $writer = Bio::MAGETAB::Util::Writer->new( magetab => $magetab );

    $writer->write();

    return;
}

sub add_file {

    my ( $self, $filename ) = @_;

}

1;
__END__

=head1 NAME

ClinStudy::MAGETAB::Dumper - MAGE-TAB export from the ClinStudy database.

=head1 SYNOPSIS

 use ClinStudy::MAGETAB::Dumper;
 my $dumper = ClinStudy::MAGETAB::Dumper->new(
     uri => $database_home_uri,
 );

 # Add annotation for each of the files being included.
 foreach my $file ( @filenames ) {
    $dumper->add_file( $file );
 }

 # Write out the MAGE-TAB files.
 $dumper->dump();

=head1 DESCRIPTION

Module created to facilitate the export of MAGE-TAB documents from the
ClinStudy database, primarily using the web-based REST API.

=head2 OPTIONS

=over 2

=item uri

The main URI of the ClinStudy web application (for example, when
running under the Catalyst test server this would be
http://localhost:3000 by default).

=item username

The username to use in connecting to the database.

=item password

The password to use in connecting to the database.

=item magetab

A Bio::MAGETAB container object. This will be created automatically by
default; this option should not typically be used unless you know what
you're doing.

=back

=head1 SEE ALSO

L<Bio::MAGETAB>, L<ClinStudy::XML::Dumper>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

