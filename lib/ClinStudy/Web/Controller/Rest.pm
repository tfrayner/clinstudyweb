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

package ClinStudy::Web::Controller::Rest;

use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

ClinStudy::Web::Controller::Rest - Catalyst Controller for the REST API

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

#__PACKAGE__->config->{serialize}{default} = 'YAML';

=head2 begin

Initial method called during a REST query. This method handles the
authentication of the user.

=cut

sub begin : ActionClass('Deserialize') {

    my ( $self, $c ) = @_;

    my $username = $c->req->header('X-Username');
    my $password = $c->req->header('X-Password');

    # Require either logged in user, or correct user and password in
    # the HTTP request headers.
    unless ( $c->user || $c->authenticate({ username => $username,
                                            password => $password }) ) {

        # Login failed
        $c->res->status(403); # Forbidden
        $c->res->body("You are not authorised to use the REST API (login failed).");
        $c->detach();
    }

    unless ( $c->check_any_user_role('user') ) {

        # Wrong user class.
        $c->res->status(403); # Forbidden
        $c->res->body("You are not authorised to use the REST API (insufficient privileges).");
        $c->detach();
    }

    return;
}

=head2 sample

A wrapper action for queries on Samples which redirects to the
appropriate GET or POST method.

=cut

sub sample : Local : ActionClass('REST') {

    my ( $self, $c, $id ) = @_;

    $c->stash(id => $id);
}

=head2 sample_GET

Query Samples by the supplied name attribute and return the
appropriate serialized hashref to the user.

=cut

sub sample_GET {

    my ( $self, $c ) = @_;

    my $id = $c->stash->{id};

    my $sample = $c->model('DB::Sample')->find({ name => $id });

    if ( $sample ) {
        $self->status_ok( $c, entity => $self->dump_sample_entity($c, $sample) );
    }
    else {
        $self->status_not_found( $c, message => 'Sample not found' );
    }

    return;
}

=head2 assay_file

A wrapper action for filename-based queries on Assays which
redirects to the appropriate GET or POST method.

=cut

sub assay_file : Local : ActionClass('REST') {

    my ( $self, $c, $id ) = @_;

    $c->stash( id => $id );
}

=head2 assay_file_GET

Query Assays by the supplied filename attribute and return the
appropriate serialized hashref to the user.

=cut

sub assay_file_GET {

    my ( $self, $c ) = @_;

    my $id = $c->stash->{id};

    my $assay = $c->model('DB::Assay')->find({ filename => $id });

    if ( $assay ) {
        $self->status_ok( $c, entity => $self->dump_assay_entity($c, $assay) );
    }
    else {
        $self->status_not_found( $c, message => 'File not found' );
    }

    return;
}

=head2 assay_barcode

A wrapper action for identifier-based queries on Assays which
redirects to the appropriate GET or POST method.

=cut

sub assay_barcode : Local : ActionClass('REST') {

    my ( $self, $c, $id ) = @_;

    $c->stash( id => $id );
}

=head2 assay_barcode_GET

Query Assays by the supplied identifier (barcode) attribute and return the
appropriate serialized hashref to the user.

=cut

sub assay_barcode_GET {

    my ( $self, $c ) = @_;

    my $id = $c->stash->{id};

    my $assay = $c->model('DB::Assay')->find({ identifier => $id });

    if ( $assay ) {
        $self->status_ok( $c, entity => $self->dump_assay_entity($c, $assay) );
    }
    else {
        $self->status_not_found( $c, message => 'Barcode not found' );
    }

    return;
}

=head2 dump_sample_entity

Given a Sample object from the database, construct a hashref suitable
for passing back to the user.

=cut

sub dump_sample_entity {

    my ( $self, $c, $sample ) = @_;

    my $visit   = $sample->visit_id();
    my $patient = $visit->patient_id();

    my %dump = (
        sample_name    => $sample->name(),
        patient_number => $patient->trial_id(),
        year_of_birth  => $patient->year_of_birth(),
        entry_date     => $patient->entry_date(),
        visit_date     => $visit->date(),
        material_type  => $sample->material_type_id()->value(),
        cell_type      => $sample->cell_type_id()->value(),
        studies        => join(', ', map { $_->type_id()->value() } $patient->studies() ),
    );

    if ( my $tp = $sample->visit_id()->nominal_timepoint_id() ) {
        $dump{time_point} = $tp->value();
    }

    # Just return the most recent diagnosis.
    my @diagnoses = map { $_->condition_name_id()->value() }
        reverse sort { $a->date() cmp $b->date() } $patient->diagnoses();
    $dump{diagnosis} = $diagnoses[0];

    my $cohort = $patient->home_centre_id();
    $dump{cohort} = $cohort ? $cohort->value() : undef;

    my $ethnicity = $patient->ethnicity_id();
    $dump{ethnicity} = $ethnicity ? $ethnicity->value() : undef;

    my $disease_activity = $visit->disease_activity_id();
    $dump{disease_activity} = $disease_activity ? $disease_activity->value() : undef;

    $dump{gender} = $patient->sex();

    my %prior = map { _xml_sanitize( $_->type_id->value() ) => $_->name() }
                $patient->prior_groups();
    $dump{prior_group} = \%prior;

    my %group = map { _xml_sanitize( $_->type_id->value() ) => $_->name() }
                $visit->emergent_groups();
    $dump{emergent_group} = \%group;

    $dump{treatment_escalations} =
        $patient->search_related( 'visits',
                                 { treatment_escalation => 1 } )->count();

    # We only want those TestResults which have no parents. FIXME is
    # there a better way via SQL::Abstract?
    my %tests = map { _xml_sanitize( $_->test_id->name() ) => _get_test_value($_) }
                grep { $_->parent_test_results()->count() == 0 }
                $visit->test_results();
    $dump{test_result} = \%tests;

    return \%dump;
}

sub _xml_sanitize {

    my ( $text ) = @_;

    # Not as expressive as the full XML spec, but this should work for
    # our purposes.
    $text =~ s/^(?=[0-9\.-])/X/;
    $text =~ s/[^[:alnum:]\.-]/_/g;

    return $text;
}

sub _get_test_value {

    my ( $result ) = @_;

    my $value = $result->value();
    unless ( defined $value ) {
        $value = $result->controlled_value_id()
               ? $result->controlled_value_id()->value()
               : undef
    }

    return $value;
}

=head2 dump_assay_entity

Given an Assay object from the database, construct a hashref suitable
for passing back to the user.

=cut

sub dump_assay_entity {

    my ( $self, $c, $assay ) = @_;

    my $batch = $assay->assay_batch_id();

    my %dump = (
        filename   => $assay->filename(),
        'info.batch.name' => $batch->name(),
        batch_date => $batch->date(),
        identifier => $assay->identifier(),
        operator   => $batch->operator(),
        platform   => $batch->platform_id()->value(),
    );

    my @channels = $assay->channels();

    my @chdata;
    foreach my $ch ( @channels ) {
        push @chdata, {
            label   => $ch->label_id()->value(),
            sample  => $self->dump_sample_entity( $c, $ch->sample_id() ),
        };
    }
    $dump{channels} = \@chdata;

    my %qc_values;
    foreach my $qc ( $assay->assay_qc_values() ) {
        my $name = $qc->name();

        # These characters can screw up any XML output.
        $name =~ s/[ \[\]\/]+/_/g;
        $qc_values{$name} = $qc->value();
    }
    $dump{qc} = \%qc_values;

    return \%dump;
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
