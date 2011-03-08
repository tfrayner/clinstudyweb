#
# This file is part of BeerFestDB, a beer festival product management
# system.
# 
# Copyright (C) 2010 Tim F. Rayner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package ClinStudy::Web::Controller::Query;
use Moose;
use namespace::autoclean;

require JSON::Any;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

ClinStudy::Web::Controller::Query - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 select

=cut

sub select : Local {

    my ( $self, $c ) = @_;

    my $dbclass = $c->request->param( 'resultSet' );
    $dbclass =~ s/.*::/DB::/;

    my $rs = $c->model($dbclass);
    if ( ! $rs ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Unrecognised ResultSet "$dbclass"};
    }
    else {

        # Run the actual query.
        my $query = $c->request->param( 'query' ) || {};
        my $attrs = $c->request->param( 'attrs' ) || {};

        my @results;
        eval {
            @results = $rs->search( $query, $attrs );
        };
        if ( $@ ) {
            $c->stash->{ 'success' } = JSON::Any->false();
            $c->stash->{ 'errorMessage' } = qq{Error in SQL query: $@};
        }
        else {
            $c->stash->{ 'success' } = JSON::Any->true();
            $c->stash->{ 'results' } = \@results;
        }
    }

    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner

This library is released under version 3 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable;

1;
