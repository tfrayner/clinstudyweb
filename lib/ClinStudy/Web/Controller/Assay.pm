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

package ClinStudy::Web::Controller::Assay;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::Assay - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::Assay' );
    $self->my_sort_field( 'identifier' );

    return;
}

=head2 add_to_sample

=cut

sub add_to_sample : Private {  # Currently not in use because assays
                               # are treated as read-only in the web
                               # UI.

    # We belabour this because of the many-to-many relationship via
    # channel. Note that editing works fine; it's just instantiating a
    # new assay linked to sample that's the problem.
    my ( $self, $c, $sample_id ) = @_;

    # Confirm we have privileges to be here.
    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    $c->stash->{template} = "assay/edit.tt2";

    # Create the new object.
    my $object = $c->model('DB::Assay')->new({ id => undef });

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $object, $c->namespace . '/edit' );

    if ( $form->submitted_and_valid() ) {

        # Make sure the AssayBatch object has been created and
        # inserted first. No idea why HTML::FormFu tries to insert the
        # main object before its dependencies, but there we are.
        my $batch;
        $c->_set_journal_changeset_attrs();
        $c->model->result_source->schema->txn_do(
            sub {
                $batch = $c->model('DB::AssayBatch')->find_or_create({
                    %{$form->params()->{'assay_batch_id'}},
                    id => undef,    # Overwrites the H::FF id => '' which buggers things up.
                });
            }
        );
        $object->set_column( assay_batch_id => $batch->id() );

        # Form was submitted and it validated.
        $c->form_values_to_database( $object, $form );

        $self->set_my_updated_message( $c, $object );

        $c->res->redirect( $c->uri_for('view', $object->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $self->set_my_updating_message( $c, $object );

        $form->model->default_values( $object );

        # Set the sample_id here.
        my $f = $form->get_fields(nested_name => 'channels.sample_id_1')
            or die("Cannot find sample_id field!");
        $f->[0]->default( $sample_id );
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $object, $sample_id);

    $c->stash->{object} = $object;

}

=head2 delete

=cut

sub delete : Private {  # Currently not in use because assays are
                        # treated as read-only in the web UI.

    my ( $self, $c, $object_id, $sample_id ) = @_;

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to delete this record.';
        $c->detach('/access_denied');
    }

    my $object = $c->model('DB::Assay')->find({ id => $object_id });

    if ( $object ) {

        if ( my $message = $c->check_model_relationships( $object ) ) {
            $c->flash->{error}
                = sprintf("Unable to delete assay; it is linked to %s", $message);

            $c->res->redirect( $c->uri_for("/sample/view", $sample_id) );
            $c->detach();
        }

        $self->set_my_deleted_message( $c, $object );

        $c->delete_database_object( $object );

        $c->res->redirect( $c->uri_for("/sample/view", $sample_id) );
        $c->detach();
    }
    else {
        $c->flash->{error} = "No such assay!";
        $c->res->redirect( $c->uri_for("/sample/view", $sample_id) );
        $c->detach();
    }
}

###################
# PRIVATE METHODS #
###################

sub set_my_breadcrumbs {

    my ( $self, $c, $object, $sample_id, $batch_id ) = @_;

    my $breadcrumbs = $self->SUPER::set_my_breadcrumbs( $c, $object );

    my @fixed = grep { $_->{path} !~ '/assay/list' } @$breadcrumbs;

    # Ideally, we would figure out how breadcrumbs should work for
    # assays with multiple non-reference channels. This just assumes
    # we're only interested in the first channel.
    if ( $object ) {
        splice( @fixed, 1, 0,
                    {
                        path  => "/patient",
                        label => "List of patients",
                    },
            );

        my $sample;
        if ( defined $sample_id ) {
            $sample = $c->model('DB::Sample')->find({ id => $sample_id });
        }
        else {
            $sample  = $object->channels->search_related('sample_id')->first();
        }

        if ( $sample ) {
            my $visit   = $sample->visit_id();
            my $patient = $visit->patient_id();
        
            splice( @fixed, 2, 0,
                    {
                        path  => "/patient/view/" . $patient->id(),
                        label => "This patient",
                    },
                    {
                        path  => "/visit/view/" . $visit->id(),
                        label => "This visit",            
                    },
                    {
                        path  => "/sample/view/" . $sample->id(),
                        label => "This sample",
                    },
                );
        }
    }
    else {

        # Typically within the AssayBatch-Assay tree.
        splice( @fixed, 1, 0,
                {
                    path  => '/assaybatch/list',
                    label => 'List of assay batches',
                },
            );

        if ( defined $batch_id ) {
            my $batch = $c->model('DB::AssayBatch')->find({ id => $batch_id });

            if ( $batch ) {
        
                splice( @fixed, 2, 0,
                        {
                            path  => "/assaybatch/view/" . $batch->id(),
                            label => "This assay batch",
                        },
                    );
            }
        }
    }

    return \@fixed;
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
