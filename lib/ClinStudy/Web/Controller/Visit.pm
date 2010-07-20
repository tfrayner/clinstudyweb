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

package ClinStudy::Web::Controller::Visit;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::PatientLinkedObject'; }

=head1 NAME

ClinStudy::Web::Controller::Visit - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::Visit' );
    $self->my_sort_field( 'date' );

    return;
}

=head2 add_to_patient

=cut

sub add_to_patient : Local {
    my ( $self, $c, $patient_id ) = @_;

    # Confirm we have privileges to be here.
    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    $c->stash->{template} = "visit/edit.tt2";

    my $patient = $c->model('DB::Patient')->find({ id => $patient_id });

    unless ( $patient ) {
        $c->flash->{error} = 'No such patient';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
    $c->stash->{container} = $patient;

    my $visit = $c->model('DB::Visit')->new({
        patient_id => $patient->id,
        id         => undef, });
    $c->stash->{object} = $visit;

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $visit, 'visit/edit' );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $form->model->update( $visit );

        # Strip the test_results out, do any calculations
        # needed, make sure they have a date (from $visit->date)
        # and get them into the database.
        $self->_process_test_values( $c, $form, $visit );

        $self->set_my_updated_message( $c, $visit, $visit->id );

        $c->res->redirect( $c->uri_for('edit_for_type', $visit->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $self->set_my_updating_message( $c, $visit, $visit->id );

        $form->model->default_values( $visit );

        # TestResults are a special case here.
        $self->_populate_test_values($c, $form, $visit);
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $visit, $patient_id);

    $c->stash->{object} = $visit;
}

=head2 edit

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;

    # Confirm we have privileges to be here.
    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    my $visit = $c->model('DB::Visit')->find({ id => $id });

    unless ( $visit ) {
        $c->flash->{error} = 'No such visit';
        $c->res->redirect( $c->uri_for('/visit/list') );
        $c->detach();
    }
    $c->stash->{object} = $visit;

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $visit );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $form->model->update( $visit );

        # Strip the test_results out, do any calculations
        # needed, make sure they have a date (from $visit->date)
        # and get them into the database.
        $self->_process_test_values( $c, $form, $visit );

        $self->set_my_updated_message( $c, $visit, $id );

        $c->res->redirect( $c->uri_for('view', $visit->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $self->set_my_updating_message( $c, $visit, $id );

        $form->model->default_values( $visit );

        # TestResults are a special case here.
        $self->_populate_test_values($c, $form, $visit);
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $visit, $visit->patient_id() );

    $c->stash->{object} = $visit;
}

=head2 edit_for_type

=cut

sub edit_for_type : Local {

    my ( $self, $c, $visit_id ) = @_;

    # Check our authorisation.
    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    # Find the visit.
    my $visit = $c->model('DB::Visit')->find({ id => $visit_id });
    unless ( $visit ) {
        $c->flash->{error} = 'No such visit';
        $c->res->redirect( $c->uri_for('/visit/list') );
        $c->detach();
    }
    $c->stash->{object} = $visit;

    # Figure out what study type we're looking at here.
    my @study_types = $visit->patient_id->studies()->search_related('type_id');
    unless ( @study_types ) {
        $c->flash->{error} =
            sprintf('No study type for patient %s', $visit->patient_id->trial_id());
        $c->res->redirect( $c->uri_for('view', $visit_id) );
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
        $form->load_config_filestem("visit/$pages[0]");
        $form->stash->{object} = $visit;
        $form->process();
        $c->stash->{form} = $form;
        $c->stash->{study_type} = $types_for_edit[0];

        if ( $form->submitted_and_valid() ) {

            # Form was submitted and it validated.
            $form->model->update( $visit );

            # Strip the test_results out, do any calculations
            # needed, make sure they have a date (from $visit->date)
            # and get them into the database.
            $self->_process_test_values( $c, $form, $visit );

            # Call any configured calculators with the updated visit.
            foreach my $study_type ( @study_types ) {
                $c->recalculate_aggregates( $visit, $study_type );
            }

            $self->set_my_updated_message( $c, $visit, $visit_id );

            $c->res->redirect( $c->uri_for('view', $visit_id) );
            $c->detach();
        }
        else {
            
            # First time through, or invalid form.
            $form->model()->default_values( $visit );

            # TestResults are a special case here.
            $self->_populate_test_values($c, $form, $visit);
        }
    }
    elsif ( @pages > 1 ) {

        # FIXME it'd be nice to be able to produce a multi-page form here.
        $c->flash->{error} =
            q{Multiple study-specific forms found; this is currently unsupported.};
        $c->res->redirect( $c->uri_for('view', $visit_id) );
        $c->detach();
        
    }
    else {

        # No study-specific form found, dispatch back to the visit view.
        $c->flash->{message} =
            q{No study-specific forms found.};
        $c->res->redirect( $c->uri_for('view', $visit_id) );
        $c->detach();
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $visit, $visit->patient_id());
}

sub _populate_test_values {

    my $self = shift;

    $self->_populate_test_cont_values( @_ );
    $self->_populate_test_val_values( @_ );
}

sub _populate_test_cont_values {

    my ( $self, $c, $form, $visit ) = @_;

    my $count = 0;
    while ( my $block = $form->get_all_element({ nested_name => "test_cont_results_$count" }) ) {
        $count++;

        my $field = $block->get_field({ name => 'controlled_value_id' })
            or die("Error: Cannot find controlled_value_id form field");

        if ( my $testname = $field->{model_config}{condition}{name} ) {

            my $test = $c->model('DB::Test')->find({ name => $testname })
                or die("Error: Cannot find test named $testname");

            my @options = sort { $a->[1] cmp $b->[1] }
                map { [ $_->id, $_->value ] }
                    $test->possible_values();
            $field->options( \@options );

            my $testfield = $block->get_field({ name => 'test_id' })
                or die("Error: Cannot find test_id form field.");
            $testfield->value( $test->id );

            if ( my $old = $c->model('DB::TestResult')->find({
                    test_id  => $test->id,
                    visit_id => $visit->id,
                }) ) {
                $field->default( $old->controlled_value_id()->id() );
            }
            elsif ( my $default = $field->{model_config}{default} ) {
                my $val = $c->model('DB::ControlledVocab')->find({
                    category => 'TestResult',
                    value    => $default,
                }) or die(qq{Error: Cannot find TestResult CV "$default".});
                $field->default( $val->id );
            }
        }
    }
}

sub _populate_test_val_values {

    my ( $self, $c, $form, $visit ) = @_;

    my $count = 0;
    while ( my $block = $form->get_all_element({ nested_name => "test_value_results_$count" }) ) {
        $count++;

        my $field = $block->get_field({ name => 'value' })
            or die("Error: Cannot find value form field");

        if ( my $testname = $field->{model_config}{condition}{name} ) {

            my $test = $c->model('DB::Test')->find({ name => $testname })
                or die("Error: Cannot find test named $testname");

            my $testfield = $block->get_field({ name => 'test_id' })
                or die("Error: Cannot find test_id form field.");
            $testfield->value( $test->id );

            if ( my $old = $c->model('DB::TestResult')->find({
                    test_id  => $test->id,
                    visit_id => $visit->id,
                }) ) {
                $field->default( $old->value() );
            }
        }
    }
}

sub _process_test_values {

    my $self = shift;

    $self->_generic_process_test_values( 'test_cont_results',
                                         'controlled_value_id',
                                         @_, );
    $self->_generic_process_test_values( 'test_value_results',
                                         'value',
                                         @_, );
}

sub _generic_process_test_values {

    my ( $self, $fieldname, $modelattr, $c, $form, $visit ) = @_;

    my @tests  = $c->req->param("$fieldname.test_id");
    my @values = $c->req->param("$fieldname.$modelattr");

    my $count = 0;
    while (defined( my $test_id = $c->req->param("${fieldname}_$count.test_id") ) ) {
        my $value = $c->req->param("${fieldname}_$count.$modelattr");
        $count++;
        next unless ( defined $value && $value ne q{} );

        my $result = $c->model('DB::TestResult')->find_or_create({
            test_id             => $test_id,
            visit_id            => $visit->id(),
            date                => $visit->date(),
        });

        $result->set_column( $modelattr => $value );
        $result->update();
    }

    my $blocks = $form->get_all_elements({ nested_name => '$fieldname' });

    foreach my $block ( @{ $blocks } ) {

        # Strip field and testfield out of the form. Ideally we'd
        # strip Block out as well, but this will probably do;
        # FIXME. N.B. this is calling a private method, very naughty.
        $block->_elements([]);
    }    
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
