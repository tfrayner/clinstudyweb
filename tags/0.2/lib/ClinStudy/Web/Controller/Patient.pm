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

package ClinStudy::Web::Controller::Patient;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::Patient - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::Patient' );
    $self->my_sort_field( 'trial_id' );

    return;
}

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my @study_types = $c->model('DB::ControlledVocab')
                        ->search({category => 'StudyType'});
    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c);    
    $c->stash->{study_types} = \@study_types;
}

=head2 list

=cut

sub list : Local {

    # A full listing of all patients is impractical.
    my ( $self, $c, @args ) = @_;

    # FIXME this is really rather brittle - it depends on the internal
    # behaviour of the superclass.
    if ( $c->stash->{'search_terms'} ) {

        # Search terms have been provided, so hand off to the superclass.
        $self->SUPER::list( $c, @args );
    }
    else {

        # No search terms, we just redirect to the index action.
        $c->res->redirect( $c->uri_for( '' ) );
        $c->detach();
    }
}

=head2 list_by_study_type

=cut

sub list_by_study_type : Local {

    my ( $self, $c, $study_type_id ) = @_;

    my @patients;

    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in Patient controller " . ref $self);

    if ( defined $study_type_id ) {
        my $cv = $c->model('DB::ControlledVocab')->find($study_type_id);
        @patients = $cv->search_related('studies')->search_related('patient_id');
        $c->stash->{list_type}     = 'Study Type';
        $c->stash->{list_category} = $cv->value();
    }
    else {

        # Return a list of patients unconnected with any studies. We
        # use raw SQL here for performance.
        @patients = $c->model('DB::Patient')->search_literal(
            'me.id not in (SELECT patient_id FROM study)');
        $c->stash->{list_type}     = 'Study Type';
        $c->stash->{list_category} = 'Non-assigned';
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c);    
    $c->stash->{objects}   = \@patients;
    $c->stash->{template}  = 'patient/list.tt2';
}

=head2 add

=cut

sub add : Local { 
    my ($self, $c) = @_; 

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to add new patient records.';
        $c->detach( '/access_denied' );
    }

    # We'll just reuse the edit template for now.
    $c->stash->{template} = 'patient/edit.tt2'; 

    # find_or_new() has a bad habit of finding the most recently
    # inserted record. We use new() instead.
    my $patient = $c->model('DB::Patient')->new({ id => undef });

    $c->stash->{object} = $patient;

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $patient );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $c->form_values_to_database( $patient, $form );

        # Set our message and pass on to the edit_for_type view.
        $c->flash->{message}
            = sprintf("Added %s", $patient->trial_id);
        $c->res->redirect( $c->uri_for('edit_for_type', $patient->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $c->stash->{message} = 'Adding a new patient';

        $form->model()->default_values( $patient );
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, $patient);
}

=head2 edit

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    my $patient;
    if ( $id ) {
        $patient = $c->model('DB::Patient')->find({ id => $id });
    }
    else {
        $patient = $c->model('DB::Patient')->new({ id => undef });
    }

    unless ( $patient ) {
        $c->flash->{error} = 'No such patient';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
    $c->stash->{object} = $patient;

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $patient );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $c->form_values_to_database( $patient, $form );

        # Set our message and pass back to list view.
        $c->flash->{message}
            = sprintf("Updated %s", $patient->trial_id);
        $c->res->redirect( $c->uri_for('view', $id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $form->model()->default_values( $patient );
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, $patient);
}

=head2 edit_for_type

=cut

sub edit_for_type : Local {

    my ( $self, $c, $patient_id ) = @_;

    # Check our authorisation.
    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    # Find the patient.
    my $patient = $c->model('DB::Patient')->find({ id => $patient_id });
    unless ( $patient ) {
        $c->flash->{error} = 'No such patient';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
    $c->stash->{object} = $patient;

    # Figure out what study type we're looking at here.
    my @study_types = $patient->studies()->search_related('type_id');
    unless ( @study_types ) {
        $c->flash->{error} =
            sprintf('No study type for patient %s', $patient->trial_id());
        $c->res->redirect( $c->uri_for('view', $patient_id) );
        $c->detach();
    }

    # This hash maps the possible values of the StudyType CV to
    # form configs specific to those study types.
    my $dispatch = $c->config->{'study_specific_forms'};

    my (@pages, @types_for_edit);
    foreach my $type ( @study_types ) {
        my $f = $dispatch->{ $type->value() };
        if ( defined $f ) {
            push @pages, $f;
            push @types_for_edit, $type->value();
        }
    }

    if ( @pages == 1 ) {

        # We handle the form manually so that we can point it at the right
        # config file.
        my $form = $self->form();
        $form->load_config_filestem("patient/$pages[0]");
        $form->stash->{object} = $patient;
        $form->process();
        $c->stash->{form} = $form;
        $c->stash->{study_type} = $types_for_edit[0];

        if ( $form->submitted_and_valid() ) {

            # Form was submitted and it validated.
            $c->form_values_to_database( $patient, $form );

            # Set our message and pass back to list view. FIXME at
            # some point we'll want to point this to
            # edit_prior_treatments, probably based on whether or
            # not the patient has prior treatments (if yes, just
            # go back to patient view).
            $c->flash->{message}
                = ( $patient_id > 0 ? 'Updated ' : 'Added ' )
                    . $patient->trial_id;
            $c->res->redirect( $c->uri_for('view', $patient_id) );
            $c->detach();
        }
        else {
            
            # First time through, or invalid form.
            $form->model()->default_values( $patient );
        }
    }
    elsif ( @pages > 1 ) {

        # FIXME it'd be nice to be able to produce a multi-page form here.
        $c->flash->{error} =
            q{Multiple study-specific forms found; this is currently unsupported.};
        $c->res->redirect( $c->uri_for('view', $patient_id) );
        $c->detach();
        
    }
    else {

        # No study-specific form found, dispatch back to the patient view.
        $c->flash->{message} =
            q{No study-specific forms found.};
        $c->res->redirect( $c->uri_for('view', $patient_id) );
        $c->detach();
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, $patient);
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
