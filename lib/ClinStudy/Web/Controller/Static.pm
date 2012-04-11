# Copyright 2010-2012 Tim Rayner, University of Cambridge
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

package ClinStudy::Web::Controller::Static;

use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

ClinStudy::Web::Controller::Static - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller used to handle static data requests. This used to
be handled by Catalyst::Plugin::Static::Simple; however we needed to
be able to block access to non-users to this area and so we handle
requests ourselves.

=head1 METHODS

=head2 default

=cut

# Serve all files under /static as static files
sub default : Path('/static') {

    my ( $self, $c ) = @_;

    # Optional, allow the browser to cache the content
    $c->res->headers->header( 'Cache-Control' => 'max-age=86400' );
    $c->serve_static; # from Catalyst::Plugin::Static
}

=head2 favicon

=cut

# Also handle requests for /favicon.ico
sub favicon : Path('/favicon.ico') {

    my ( $self, $c ) = @_;

    $c->serve_static('image/vnd.microsoft.icon');
}

sub end : Private {

    my ( $self, $c ) = @_;

    $c->forward( 'ClinStudy::Web::View::HTML' ) 
        unless ( $c->res->body || !$c->stash->{template} );
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2012 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable();

1;
