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

package ClinStudy::Web::Controller::SampleDataFile;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::SampleDataFile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::SampleDataFile' );
    $self->my_sort_field( 'filename' );

    return;
}

sub _set_my_breadcrumbs {

    my ( $self, $c, $object, $patient_id ) = @_;

    my $breadcrumbs = $self->SUPER::_set_my_breadcrumbs( $c, $object );

    my @fixed = grep { $_->{path} !~ '/sampledatafile/list' } @$breadcrumbs;

    splice( @fixed, 1, 0, {
        path  => "/patient",
        label => "List of patients",
    } );

    if ( $object ) {
        my $container = $object->sample_id();

        splice( @fixed, 2, 0,
                {
                    path  => "/patient/view/" . $container->visit_id()->patient_id()->id(),
                    label => "This patient",
                },        
                {
                    path  => "/visit/view/" . $container->visit_id()->id(),
                    label => "This visit",
                },        
                {
                    path  => "/sample/view/" . $container->id(),
                    label => "This sample",
                },
            );
    }

    return \@fixed;
}


=head1 AUTHOR

tfr23

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
