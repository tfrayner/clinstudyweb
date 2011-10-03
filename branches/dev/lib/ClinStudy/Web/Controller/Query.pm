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

use List::Util qw(first);
require JSON::Any;
require DateTime;
require DateTime::Format::MySQL;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

ClinStudy::Web::Controller::Query - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 json_login

This is the primary authentication method which is to be used prior to
any other queries in order to obtain an authenticated connection. See
e.g. the curl documentation for details on how this may be used (RCurl
example available in the associated ClinStudyWeb R package). Success
or failure is denoted by a boolean "success" flag in the returned
object.

=cut

sub json_login : Global {

    my ( $self, $c ) = @_;

    # Here $query is a hashref with keys username and password.
    my $query = $self->_decode_json( $c );

    # This is stupidly explicit, considering, but may help avoid
    # mistakes in future.
    if ( $c->authenticate({ username => $query->{'username'},
                            password => $query->{'password'}, }) ) {

        # Note that we're deliberately not setting the access date
        # here; read-only programmatic access is not of much interest
        # for audit purposes. Perhaps revisit this if we ever allow
        # read-write access in the JSON API.

        $c->stash->{ 'success' } = JSON::Any->true();
    }
    else {
        $c->stash->{ 'errorMessage' } = qq{Error: Unable to authenticate.};
        $c->stash->{ 'success' } = JSON::Any->false();
    }

    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head2 json_logout

A method which simply deauthenticates the user.

=cut

sub json_logout : Global {

    my ( $self, $c ) = @_;

    # Whatever happens we want to log out.
    $c->logout;
    
    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head2 index

This is the core of the generic JSON query API. JSON parameters are as
follows: resultSet, condition, attributes. These parameters are passed
in as a hashref named "data". Return values are similarly passed under
a "data" key. Success or failure is denoted by a boolean "success"
flag in the returned object.

=cut

sub index : Path {

    my ( $self, $c ) = @_;

    # Here $query is a hashref with keys resultSet, cond and attrs.
    my $query = $self->_decode_json( $c );

    my $dbclass = $query->{ 'resultSet' };
    if ( ! $dbclass ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: No resultSet JSON query attribute specified.};
        $c->detach( $c->view( 'JSON' ) );
    }
    $dbclass =~ s/^(?:.*::)?/DB::/;

    # User privileges tables are off-limits
    if ( first { $_ eq $dbclass } qw( DB::User DB::Role DB::UserRole ) ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: JSON access to that table is not permitted.};
        $c->detach( $c->view( 'JSON' ) );
    }

    # This will generally refuse to fail, even if $dbclass is empty.
    my $rs = $c->model($dbclass);

    # Run the actual query.
    my $cond  = $query->{ 'condition' }  || {};
    my $attrs = $query->{ 'attributes' } || {};
    
    my @results;
    eval {
        @results = $rs->search( $cond, $attrs );
    };
    if ( $@ ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error in SQL query: $@};
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->true();

        # Just take the column values and put them in a hash for JSON encoding.
        my @hashes;
        foreach my $res ( @results ) {
            push @hashes, { $res->get_columns() };
        }

        $c->stash->{ 'data' } = \@hashes;
    }
    
    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head2 assay_dump

=cut

sub assay_dump : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Assay');

    my ( $assay, $id );
    if ( defined ( $id = $query->{filename} ) ) {
        $assay = $rs->find({ filename => $id });
    }
    elsif ( defined ( $id = $query->{identifier} ) ) {
        $assay = $rs->find({ identifier => $id });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include either filename or identifier.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $assay ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' } = $self->dump_assay_entity($c, $assay);
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Assay "$id" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 sample_dump

=cut

sub sample_dump : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Sample');
    my ( $sample, $name );
    if ( defined ( $name = $query->{name} ) ) {
        $sample = $rs->find({ name => $name });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include sample name.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $sample ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' } = $self->dump_sample_entity($c, $sample);
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Sample "$name" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 assay_drugs

=cut

sub assay_drugs : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Assay');

    my ( $assay, $id );
    if ( defined ( $id = $query->{filename} ) ) {
        $assay = $rs->find({ filename => $id });
    }
    elsif ( defined ( $id = $query->{identifier} ) ) {
        $assay = $rs->find({ identifier => $id });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include either filename or identifier.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $assay ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' } = $self->dump_assay_drugs($c, $assay, $query);
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Assay "$id" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

###################
# Private methods #
###################

sub _decode_json : Private {

    my ( $self, $c ) = @_;

    my $j    = JSON::Any->new;
    my $query;
    eval {
        $query = $j->jsonToObj( $c->request->param( 'data' ) );
    };
    if ( $@ ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Unable to decode JSON request: $@};
        $c->detach( $c->view( 'JSON' ) );
    }

    return $query;
}

=head2 dump_assay_entity

Given an Assay object from the database, construct a hashref suitable
for passing back to the user (Private method).

=cut

sub dump_assay_entity : Private {

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

=head2 dump_sample_entity

Given a Sample object from the database, construct a hashref suitable
for passing back to the user (Private method).

=cut

sub dump_sample_entity : Private {

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
        cell_purity    => $sample->cell_purity(),
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

    my %prior = map { $_->type_id->value() => $_->name() }
                $patient->prior_groups();
    $dump{prior_group} = \%prior;

    my %group = map { $_->type_id->value() => $_->name() }
                $visit->emergent_groups();
    $dump{emergent_group} = \%group;

    my %ptreat = map { $_->type_id->value() => $_->value() }
                 grep { defined $_->value() && $_->value ne q{} }
                 $patient->prior_treatments();
    $dump{prior_treatment} = \%ptreat;
    
    $dump{treatment_escalations} =
        $patient->search_related( 'visits',
                                 { treatment_escalation => 1 } )->count();

    $dump{has_infection} = $visit->has_infection();

    # We only want those TestResults which have no parents. FIXME is
    # there a better way via SQL::Abstract?
    my %tests = map { $_->test_id->name() => _get_test_value($_) }
                grep { $_->parent_test_results()->count() == 0 }
                $visit->test_results();
    $dump{test_result} = \%tests;

    return \%dump;
}

sub dump_assay_drugs : Private {

    my ( $self, $c, $assay, $query ) = @_;

    my %dump;
    my @channels = $assay->channels();

    my @chdata;
    foreach my $ch ( @channels ) {
        push @chdata, {
            label   => $ch->label_id()->value(),
            sample  => $ch->sample_id()->name(),
            drugs   => $self->dump_sample_drugs( $c, $ch->sample_id(), $query ),
        };
    }
    $dump{channels} = \@chdata;

    return \%dump;
}

sub dump_sample_drugs : Private {

    my ( $self, $c, $sample, $query ) = @_;

    my @dump;

    # $query keys may contain months_prior, prior_treatment_type,
    # drug_type. Note that drug_type can be used to filter both
    # DrugType and DrugName CVs. Both that filter and any synonym_of
    # or part_of pointers must be resolved recursively (with a check
    # on cycles FIXME).

    my $curr_visit = $sample->visit_id();
    my $patient    = $curr_visit->patient_id();

    my $synonym_of = $c->model('DB::ControlledVocab')->find({
        category => 'CVRelationshipType',
        value    => 'synonym_of',
    }) or die("Error: synonym_of CV is not present in database.");
    my $has_part   = $c->model('DB::ControlledVocab')->find({
        category => 'CVRelationshipType',
        value    => 'has_part',
    }) or die("Error: has_part CV is not present in database.");

    my $drug_rs;
    if ( my $prior_type = $query->{'prior_treatment_type'} ) {

        # Undated prior drug treatments, categorised.
        my $pt_cv = $c->model('DB::ControlledVocab')->find({category => 'TreatmentType',
                                                            value    => $prior_type});

        unless ( $pt_cv ) {
            $c->stash->{ 'success' } = JSON::Any->false();
            $c->stash->{ 'errorMessage' }
                = qq{PriorTreatmentType "$prior_type" not found in database.};
            $c->detach( $c->view( 'JSON' ) );
        }
        $drug_rs = $patient->search_related('prior_treatments', { type_id => $pt_cv->id() })
                           ->search_related('drugs')
                           ->search_related('name_id');
    }
    else {

        # Drug treatments related to documented clinical visits.
        my $vdate        = $curr_visit->date();
        my @date_query   = ( 'date' => { '<' => $vdate } );

        # Limit query to N months prior.
        my $months_prior = $query->{'months_prior'};
        if ( defined $months_prior ) {

            ## Calculate the prior date and add it to @date_query.
            my ( $y, $m, $d ) = ( $vdate =~ m/(\d{4})-(\d{2})-(\d{2})/ );
            my $dt = DateTime->new( year => $y, month => $m, day => $d );
            my $pt = $dt->subtract( months => $months_prior );
            my $prior_date = DateTime::Format::MySQL->format_datetime( $pt );

            push @date_query, ( 'date' => { '>' => $prior_date } );
            @date_query = ( '-and' => [ @date_query ] );
        }
        
        $drug_rs = $patient->search_related('visits', { @date_query })
                           ->search_related('drugs')
                           ->search_related('name_id');
    }

    # Resolve synonym_of and has_part relationships.
    my @drug_cvs;

    my $leaves  = $self->_find_all_related_leaves( $c, $drug_rs, [ $synonym_of->id(), $has_part->id() ] );
    my $leaf_rs = $c->model('DB::ControlledVocab')->search( { id => { 'in' => $leaves } } );
    
    while ( my $cv = $leaf_rs->next() ) { push @drug_cvs, $cv }

    # This is recursive as well; there might be multiple levels of
    # is_a relationships.
    if ( my $drug_type = $query->{'drug_type'} ) {

        # Examine @drug_cvs to find things which match drug_type.
        my $isa = $c->model('DB::ControlledVocab')
                    ->find({ category => 'CVRelationshipType',
                             value    => 'is_a' })
                        or die(qq{Error: is_a CV is not present in database});

        # Also support drug_name here as an option.
        my $start_rs = $c->model('DB::ControlledVocab')
                         ->search({ 'me.category' => [ 'DrugType', 'DrugName' ],
                                    'me.value'    => $drug_type });

        # Recursion here.
        my %wanted = map { $_ => 1 } @{ $self->_find_all_isa_children( $start_rs, $isa->id() ) };

        foreach my $cv ( @drug_cvs ) {
            push @dump, $cv->value() if $wanted{ $cv->id() };
        }
    }
    else {

        # Dump everything.
        @dump = map { $_->value() } @drug_cvs;
    }

    return \@dump;
}

sub _find_all_isa_children : Private {

    ## Recursive function to take a CV ResultSet, the is_a
    ## relationship CV term, and find all linked is_a terms. Typically
    ## called with the output of $c->model()->search();

    ## FIXME this is currently vulnerable to cycles in the ontology.
    my ( $self, $start_rs, $isa_query ) = @_;

    return [] unless $start_rs->count() > 0;

    my %wanted;
    while ( my $cv = $start_rs->next() ) {
        $wanted{ $cv->id() }++;
    }

    my $rs = $start_rs->search_related('related_vocab_target_ids',
                                       { 'related_vocab_target_ids.relationship_id'
                                             => $isa_query })
                      ->search_related('controlled_vocab_id');
    
    my $sub = $self->_find_all_isa_children( $rs, $isa_query );

    foreach my $s ( @$sub ) { $wanted{ $s }++ }

    return [ keys %wanted ];
}

sub _find_all_related_leaves : Private {

    ## Basically this is an almost complementary method to
    ## _find_all_isa_children, scanning up through the ontology DAG
    ## instead of down. It differs, however, in only including leaf
    ## terms in the results. FIXME the same caveats apply, especially
    ## regarding cycles.
    my ( $self, $c, $start_rs, $related_query ) = @_;

    return [] unless $start_rs->count() > 0;

    ## We need to process the records in $start_rs to include them as leaves.
    my %wanted;
    while ( my $cv = $start_rs->next() ) {

        ## Only take leaf terms.
        my $num_targets = $c->model('DB::RelatedVocab')->search({
            controlled_vocab_id => $cv->id(),
            relationship_id     => $related_query
        })->count();
        if ( $num_targets == 0 ) {
            $wanted{ $cv->id() }++;
        }
    }

    my $rs = $start_rs->search_related('related_vocab_controlled_vocab_ids',
                                       { 'related_vocab_controlled_vocab_ids.relationship_id'
                                             => $related_query })
                      ->search_related('target_id');
    
    my $sub = $self->_find_all_related_leaves( $c, $rs, $related_query );

    foreach my $s ( @$sub ) { $wanted{ $s }++ }

    return [ keys %wanted ];
}

sub _get_test_value : Private {

    my ( $result ) = @_;

    my $value = $result->value();
    unless ( defined $value ) {
        $value = $result->controlled_value_id()
               ? $result->controlled_value_id()->value()
               : undef
    }

    return $value;
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
