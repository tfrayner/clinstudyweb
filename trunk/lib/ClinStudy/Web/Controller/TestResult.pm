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

package ClinStudy::Web::Controller::TestResult;

use strict;
use warnings;

use parent 'ClinStudy::Web::Controller::FormFuBase';

use Scalar::Util qw(blessed);

=head1 NAME

ClinStudy::Web::Controller::TestResult - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'DB::TestResult' );
    $self->my_sort_field( 'date' );
    $self->my_container_namespace( undef );

    return $self;
}

=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # We only want tests that are habitually attached to Visit or
    # Hospitalisation. We use raw SQL here for performance.
    my @tests = $c->model('DB::TestResult')->search_literal(
        'me.id not in (SELECT test_result_id FROM test_aggregation)'
    )->search_related('test_id', {}, { group_by => 'name, id' });

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);

    $c->stash->{tests} = \@tests;
}

=head2 list_by_test

=cut

sub list_by_test : Local {

    my ( $self, $c, $test_id ) = @_;

    my @test_results;
    if ( $test_id ) {
        @test_results = $c->model('DB::TestResult')->search({ test_id => $test_id });
    }
    else {
        $c->flash->{error} = 'No test ID (this is a page navigation error).';
        $c->res->redirect( $c->uri_for('/testresult') );
        $c->detach();
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
    $c->stash->{objects}  = \@test_results;
    $c->stash->{template} = 'testresult/list.tt2';
}

=head2 list_by_patient 

=cut

sub list_by_patient : Local {
    my ( $self, $c, $patient_id, $test_id ) = @_;

    unless ( $patient_id ) {
        $c->flash->{error} = 'No patient ID (this is a page navigation error).';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }

    my $patient = $c->model('DB::Patient')->find({id => $patient_id});
    if ( ! $patient ) {
        $c->flash->{error} = 'No such patient!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }

    $c->stash->{container} = $patient;

    # This is used to filter out results which have parent aggregate test results.
    my $aggregate_rs = $c->model('DB::TestAggregation');

    if ( $test_id ) {

        # These are sorted in the view.

        # This has been optimised as much as possible to run complex
        # queries in the database engine, rather than reorganising the
        # results in perl after the query.
        my @test_results = 
            $patient->visits()->search_related(
                'test_results',
                {
                    'test_results.id' => {
                        'NOT IN' => $aggregate_rs->get_column('test_result_id')->as_query() },
                    'test_id.id' => $test_id,
                },
                {
                    join     => 'test_id',
                    prefetch => 'test_id',
                    order_by => 'date',
                })->all(),
            $patient->hospitalisations()->search_related(
                'test_results',
                {
                    'test_results.id' => {
                        'NOT IN' => $aggregate_rs->get_column('test_result_id')->as_query() },
                    'test_id.id' => $test_id,
                },
                {
                    join     => 'test_id',
                    prefetch => 'test_id',
                    order_by => 'date',
                })->all();
        
        $c->stash->{objects} = \@test_results;
    }
    else {

        # Again, only show tests which have results lacking aggregates.
        my @tests =
             $patient->visits()
                     ->search_related('test_results',{
                         'test_results.id' => {
                             'NOT IN' => $aggregate_rs->get_column('test_result_id')->as_query() }
                     })
                     ->search_related('test_id',{},{distinct => 1})->all(),
             $patient->hospitalisations()
                     ->search_related('test_results',{
                         'test_results.id' => {
                             'NOT IN' => $aggregate_rs->get_column('test_result_id')->as_query() }
                     })
                     ->search_related('test_id',{},{distinct => 1})->all();
        $c->stash->{tests} = \@tests;
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, undef, $patient_id);
}

=head2 add_to_visit

=cut

sub add_to_visit : Local {
    my ( $self, $c, $visit_id ) = @_;

    # Add a new result to $visit. Check that the visit exists:
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

    # Add a new result to $hospitalisation. Check that the hospitalisation exists:
    my $hospitalisation = $c->model('DB::Hospitalisation')->find({id => $hospitalisation_id});
    if ( ! $hospitalisation ) {
        $c->flash->{error} = 'No such hospitalisation event!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }

    $c->forward('edit', [undef, $hospitalisation]);
}

=head2 add_to_test_result

=cut

sub add_to_test_result : Local {
    my ( $self, $c, $test_result_id ) = @_;

    # Add a new result to $test_result. Check that the test_result exists:
    my $test_result = $c->model('DB::TestResult')->find({id => $test_result_id});
    if ( ! $test_result ) {
        $c->flash->{error} = 'No such test result!';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }

    $c->forward('edit', [undef, $test_result]);
}

=head2 edit

=cut

sub edit : Local {
    my ( $self, $c, $result_id, $resultholder ) = @_;

    # This runmode will handles a generic "result-associated" object:
    # Visit or Hospitalisation. We pass in the object rather than its
    # id.

    # We define most of our own form here in the controller for
    # TestResult, to allow us to distinguish between free-response
    # tests and those returning controlled values.

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    $c->stash->{template} = 'testresult/edit.tt2';

    # Sort out how we will handle the $resultholder object.
    my $holderclass = blessed( $resultholder );

    my ( $result, $test );
    if ( ! $result_id && $resultholder ) {

        # Variables use to direct the polymorphic nature of this runmode.
        my ( $id_method, $redirect ) = $c->_redirect_from_classname( $holderclass );

        # Add a new result to $resultholder. Create the new result:
        if ( $id_method ) {

            # Straightforward one-to-many; result holder is Visit or Hospitalisation.
            $result = $c->model('DB::TestResult')->new({ id         => undef,
                                                         $id_method => $resultholder });
        }
        elsif ( $holderclass =~ /::TestResult \z/xms ) {

            # Aggregate/Child test results are a special case.
            $result = $c->model('DB::TestResult')->new({
                id                 => undef,
                visit_id           => $resultholder->visit_id(),
                hospitalisation_id => $resultholder->hospitalisation_id(),
            });
        }
        else {
            $c->stash->{error} = "Unable to process object $resultholder";
            $c->detach('/default');
        }

        my $test_id = $c->req->param('test_id');
        $test = $c->model('DB::Test')->find({id => $test_id});
    }
    else {

        # Edit a pre-existing result.
        $result = $c->model('DB::TestResult')->find({ id => $result_id });
        if ( ! $result ) {
            $c->flash->{error} = 'No such test result!';
            $c->res->redirect( $c->uri_for('/patient') );
            $c->detach();
        }
        $test = $result->test_id;
    }

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $result, 'testresult/edit' );

    # Set up the form here to take into account the requirements of $test.
    if ( $test ) {
        $self->_add_value_fields( $form, $test );
    }

    # Re-process the form before rendering.
    $form->process();

    # Now we check return values.
    if ( $form->submitted_and_valid() 
             && scalar grep { defined $form->param_value($_) }
                 qw(value min_value max_value controlled_value_id) ) {
        
        # Form was submitted and it validated, and it has at least one value.
        $form->model->update( $result );

        # If the holder is a parent test result, we need to link it up
        # *after* the database has been updated.
        if ( $holderclass =~ /::TestResult \z/xms ) {
            $c->model('DB::TestAggregation')->find_or_create({
                aggregate_result_id => $resultholder,
                test_result_id      => $result,
            });
        }

        # Call any configured calculators with the updated
        # visit. N.B. this means that editing an aggregate result may
        # be futile if it's immediately overwritten by a recalculated
        # result. This is more or less by design.
        my $container = $result->visit_id()
                     || $result->hospitalisation_id()
                     || confess("Database error: test result orphaned!");
        my @studies = $container->patient_id()->studies();
        foreach my $study_type ( map { $_->type_id() } @studies ) {
            $c->recalculate_aggregates( $container, $study_type );
        }

        $self->set_my_updated_message( $c, $result, $result_id );

        $c->res->redirect( $c->uri_for('view', $result->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $self->set_my_updating_message( $c, $result, $result_id );
        
        $form->model->default_values( $result );

        # Add a default date for new results, as a convenience.
        my $date_field = $form->get_field('date');
        if ( ! defined( $date_field->value ) && defined $resultholder ) {
            $date_field->value( $resultholder->date() );
        }
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $result);

    $c->stash->{object} = $result;
}

=head2 delete

=cut

sub delete : Local {

    my ( $self, $c, $result_id ) = @_;

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to delete this record.';
        $c->detach('/access_denied');
    }

    my $result = $c->model('DB::TestResult')->find({ id => $result_id });

    if ( $result ) {

        my ( $id_method, $redirect ) = $c->_redirect_from_dbobj( $result );

        unless ( $redirect ) {
            $c->stash->{error} = "Unable to redirect from test result!";
            $c->detach('/default');
        }
        
        if ( my $message = $c->check_model_relationships( $result ) ) {
            $c->flash->{error}
                = sprintf("Unable to delete test result; it is linked to %s", $message);
            $c->res->redirect( $redirect );
            $c->detach();
        }
            
        $self->set_my_deleted_message( $c, $result );

        $result->delete;

        $c->res->redirect( $redirect );
        $c->detach();
    }
    else {
        $c->flash->{error} = 'No such test result';
        $c->res->redirect( $c->uri_for('/patient') );
        $c->detach();
    }
}

sub _add_value_fields {

    # FIXME it might be better to just repoint to a new form config
    # rather than messing about here. That would make creating complex
    # DependsOn relationships a little easier (e.g. for value,
    # min_value and max_value).
    my ( $self, $form, $test ) = @_;

    my @elements;

    my @options = map { [ $_->id() => $_->value() ] } $test->possible_values();
    if ( scalar @options ) {
        unshift @options, [ q{} => '-select-' ];   # Bug in HTML::FormFu??
        my $elem = $form->element({
            type              => 'Select',
            name              => 'controlled_value_id',
            label             => 'Value',
            options           => \@options,
            constraints       => 'Required',
        });
        push @elements, $elem;
    }
    else {
        push @elements, map {
            my $l = ucfirst($_);
            $l =~ s/_+/ /g;
            $form->element({
                type    => 'Text',
                name    => $_,
                label   => $l,
                constraints => [ 'Required', 'ASCII', { type => 'Length', min => 1, max => 20 } ],
            })
        } qw(value);   # FIXME maybe revisit min_value, max_value later.
    }

    # insert_before doesn't do a recursive search, so we use
    # parent() to find where we need to add the new element.
    my $submit = $form->get_all_element({ name => 'submit_buttons', type=>'Src' })
        or die("Error: Submit element not found in form construction.");
    $submit->parent->insert_before( $_, $submit ) for @elements;

    # Limit our select list.
    my $select = $form->get_all_element({ name => 'test_id', type=>'Select' });
    if ( $select ) {
        $select->options([[ $test->id() => $test->name() ]]);
    }

    return;
}

sub set_my_breadcrumbs {

    my ( $self, $c, $object, $patient_id ) = @_;

    my $breadcrumbs = $self->SUPER::set_my_breadcrumbs( $c, $object );

    my @fixed = grep { $_->{path} !~ '/testresult/list' } @$breadcrumbs;

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
                    path  => "/testresult/list_by_patient/$patient_id",
                    label => "Test results",            
                });
    }
    elsif ( $object ) {
        my $container = $object->visit_id()
            || $object->hospitalisation_id()
            || confess("Database error: test result orphaned!");

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
            path  => "/testresult/list",
            label => "Test results",            
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

1;
