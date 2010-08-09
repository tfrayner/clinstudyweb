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

package ClinStudy::Web::Controller::Drug;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::Drug - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::Drug' );
    $self->my_sort_field( 'name_id' );

    return;
}

=head2 list_by_patient 

=cut

sub list_by_patient : Local {
    my ( $self, $c, $patient_id ) = @_;

    my %drugs_by_date;
    if ( $patient_id ) {
        my $patient = $c->model('DB::Patient')->find({id => $patient_id});
        if ( ! $patient ) {
            $c->flash->{error} = 'No such patient!';
            $c->res->redirect( $c->uri_for('/patient') );
            $c->detach();
        }

        foreach my $visit ( $patient->visits() ) {
            my @drugs = $visit->drugs();
            push @{ $drugs_by_date{ $visit->date() } }, @drugs if scalar @drugs;
        }
        foreach my $hospitalisation ( $patient->hospitalisations() ) {
            my @drugs = $hospitalisation->drugs();
            push @{ $drugs_by_date{ $hospitalisation->date() } }, @drugs if scalar @drugs;
        }
        foreach my $prior_treatment ( $patient->prior_treatments() ) {
            my @drugs = $prior_treatment->drugs();
            push @{ $drugs_by_date{ $prior_treatment->type_id()->value() } }, @drugs if scalar @drugs;
        }

        $c->stash->{container} = $patient;
    }
    else {
        $c->flash->{error} = 'No patient ID (this is a page navigation error).';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, undef, $patient_id);

    $c->stash->{drugs_by_date} = \%drugs_by_date;
}

=head2 add_to_priortreatment

=cut

sub add_to_priortreatment : Local {
    my ( $self, $c, $treatment_id ) = @_;
    $c->stash->{template} = 'drug/edit.tt2';

    # Add a new drug to $treatment. Check that the treatment exists:
    my $treatment = $c->model('DB::PriorTreatment')->find({id => $treatment_id});
    if ( ! $treatment ) {
        $c->flash->{error} = 'No such treatment!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
    $c->forward('edit', [undef, $treatment]);
}

=head2 add_to_visit

=cut

sub add_to_visit : Local {
    my ( $self, $c, $visit_id ) = @_;
    $c->stash->{template} = 'drug/edit.tt2';

    # Add a new drug to $visit. Check that the visit exists:
    my $visit = $c->model('DB::Visit')->find({id => $visit_id});
    if ( ! $visit ) {
        $c->flash->{error} = 'No such visit!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
    $c->forward('edit', [undef, $visit]);
}

=head2 add_to_hospitalisation

=cut

sub add_to_hospitalisation : Local {
    my ( $self, $c, $hospitalisation_id ) = @_;
    $c->stash->{template} = 'drug/edit.tt2';

    # Add a new drug to $hospitalisation. Check that the hospitalisation exists:
    my $hospitalisation = $c->model('DB::Hospitalisation')->find({id => $hospitalisation_id});
    if ( ! $hospitalisation ) {
        $c->flash->{error} = 'No such hospitalisation!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
    $c->forward('edit', [undef, $hospitalisation]);
}

=head2 edit

=cut

sub edit : Local {
    my ( $self, $c, $drug_id, $drugholder ) = @_;

    # This runmode will handles a generic "drug-associated" object:
    # PriorTreatment, Visit or Hospitalisation. We pass in the
    # object rather than its id.

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    my $drug;
    if ( ! $drug_id && $drugholder ) {

        # Sort out how we will handle the $drugholder object.
        my $holderclass = blessed( $drugholder );

        # Variables use to direct the polymorphic nature of this runmode.
        my ( $id_method, $redirect ) = $c->_redirect_from_classname( $holderclass );
        unless ( $id_method ) {
            $c->stash->{error} = "Unable to process object $drugholder";
            $c->detach('/default');
        }
       
        # Add a new drug to $drugholder. Create the new drug:
        $drug = $c->model('DB::Drug')->new({ $id_method => $drugholder });
    }
    else {

        # Edit a pre-existing drug.
        $drug = $c->model('DB::Drug')->find({ id => $drug_id });
        if ( ! $drug ) {
            $c->flash->{error} = 'No such drug treatment!';
            $c->res->redirect( $c->uri_for('/patient') );
            $c->detach();
        }
    }

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $drug, 'drug/edit' );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $c->form_values_to_database( $drug, $form );

        $c->flash->{message}
            = sprintf("%s %s %s drug treatment",
                      ( $drug_id && $drug_id > 0 ? 'Updated ' : 'Added new '),
                      ( $drug->locale_id ? $drug->locale_id->value : q{} ),
                      ( $drug->name_id   ? $drug->name_id->value   : 'drug' ) );

        my ( $id_method, $redirect ) = $c->_redirect_from_dbobj( $drug );
        $c->res->redirect( $redirect );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $c->stash->{message}
            = sprintf("%s %s %s drug treatment",
                      ( $drug_id && $drug_id > 0 ? 'Updating a ' : 'Adding a new '),
                      ( $drug->locale_id ? $drug->locale_id->value : q{} ),
                      ( $drug->name_id   ? $drug->name_id->value   : q{} ) );

        $form->model->default_values( $drug );
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $drug);

    $c->stash->{object}   = $drug;
}

=head2 delete

=cut

sub delete : Local {

    my ( $self, $c, $drug_id ) = @_;

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to delete this record.';
        $c->detach('/access_denied');
    }

    my $drug = $c->model('DB::Drug')->find({ id => $drug_id });

    if ( $drug ) {

        my ( $id_method, $redirect ) = $c->_redirect_from_dbobj( $drug );
        unless ( $redirect ) {
            $c->stash->{error} = "Unable to redirect from drug!";
            $c->detach('/default');
        }

        if ( my $message = $c->check_model_relationships( $drug ) ) {
            $c->flash->{error}
                = sprintf("Unable to delete drug; it is linked to %s", $message);
            $c->res->redirect( $redirect );
            $c->detach();
        }
            
        $c->flash->{message}
            = sprintf("Deleted %s %s drug treatment",
                      ( $drug->locale_id ? $drug->locale_id->value : q{} ),
                      ( $drug->name_id   ? $drug->name_id->value   : q{} ) );

        $c->delete_database_object( $drug );

        $c->res->redirect( $redirect );
        $c->detach();
    }
    else {
        $c->flash->{error} = 'No such drug treatment!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
}

sub set_my_breadcrumbs {

    my ( $self, $c, $object, $patient_id ) = @_;

    my $breadcrumbs = $self->SUPER::set_my_breadcrumbs( $c, $object );

    my @fixed = grep { $_->{path} !~ '/drug/list' } @$breadcrumbs;

    splice( @fixed, 1, 0, {
        path  => "/patient",
        label => "List of patients",
    } );

    if ( defined $patient_id ) {
        splice( @fixed, 2, 0,
                {
                    path  => "/patient/view/$patient_id",
                    label => "This patient",
                },
                {   # N.B. this will typically not be linked.
                    path  => "/drug/list_by_patient/$patient_id",
                    label => "Drugs",            
                });
    }
    elsif ( $object ) {
        my $container = $object->visit_id()
            || $object->hospitalisation_id()
            || $object->prior_treatment_id()
            || confess("Database error: drug treatment orphaned!");

        my $holderclass = blessed $container;
        my ( $holder_namespace ) = ( lc($holderclass) =~ /::([^:]+)\z/xms );
        unless ( $holder_namespace ) {
            confess("Error: Cannot determine holder class namespace for $holderclass.");
        }

        splice( @fixed, 2, 0,
                {
                    path  => "/patient/view/" . $container->patient_id()->id(),
                    label => "This patient",
                },        
                {
                    path  => "/$holder_namespace/view/" . $container->id(),
                    label => "This $holder_namespace",
                },
            );
    }
    else {
        splice( @fixed, 2, 0, {
            # N.B. this will typically not be linked.
            path  => "/drug/list",
            label => "Drugs",            
        });
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
