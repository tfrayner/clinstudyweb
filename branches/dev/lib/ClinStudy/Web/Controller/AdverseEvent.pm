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

package ClinStudy::Web::Controller::AdverseEvent;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::PatientLinkedObject'; }

use Carp;

=head1 NAME

ClinStudy::Web::Controller::AdverseEvent - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::AdverseEvent' );
    $self->my_sort_field( 'start_date' );

    return;
}

=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @severities = $c->model('DB::ControlledVocab')
                       ->search({category => 'AdverseSeverity'});
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);    
    $c->stash->{severities} = \@severities;
}

=head2 list_by_severity

=cut

sub list_by_severity : Local {

    my ( $self, $c, $severity_id ) = @_;

    my @adverses;

    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in AdverseEvent controller " . ref $self);

    if ( $severity_id ) {
        @adverses = $c->model($class)
                      ->search({ severity_id => $severity_id });
    }
    else {
        $c->flash->{error} = 'No severity ID (this is a page navigation error).';
        $c->res->redirect( $c->uri_for('/adverseevent') );
        $c->detach();
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);    
    $c->stash->{objects}   = \@adverses;
    $c->stash->{list_type} = 'Severity';
    $c->stash->{template}  = 'adverseevent/list.tt2';
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable();

1;
