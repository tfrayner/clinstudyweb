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

package ClinStudy::Web::Controller::Sample;

use strict;
use warnings;

use parent 'ClinStudy::Web::Controller::VisitLinkedObject';

=head1 NAME

ClinStudy::Web::Controller::Sample - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'DB::Sample' );
    $self->my_sort_field( 'name' );

    return $self;
}

sub view : Local {

    my ( $self, $c, $object_id ) = @_;

    # Populate the majority of the context stash.
    $self->SUPER::view( $c, $object_id );

    my $object = $c->model('DB::Sample')->find({ id => $object_id });

    my @assays = $object->channels()->search_related('assay_id');

    $c->stash->{assays} = \@assays;
}

sub assay_report : Local {

    my ( $self, $c ) = @_;

    my @study_types = $c->model('DB::ControlledVocab')
                        ->search({category => 'StudyType'});
    my @platforms   = $c->model('DB::ControlledVocab')
                        ->search({category => 'PlatformType'});
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);    
    push @{ $c->stash->{breadcrumbs} }, {
        path  => '/sample/assay_report',
        label => 'Assay reports',
    };
    $c->stash->{platforms}   = \@platforms;
    $c->stash->{study_types} = \@study_types;
}

sub assay_report_by_study_type : Local {

    # This method does some heavy lifting which doesn't scale
    # spectacularly well.
    
    my ( $self, $c, $study_type_id, $platform_id ) = @_;

    if ( ! defined $study_type_id ) {
        $c->flash->{error} = 'No study type ID (this is a page navigation error).';
        $c->res->redirect( $c->uri_for('/sample/assay_report') );
        $c->detach();
    }

    my $cv = $c->model('DB::ControlledVocab')->find($study_type_id);
    $c->stash->{study_type} = $cv->value;

    if ( defined $platform_id ) {
        my $pt = $c->model('DB::ControlledVocab')->find($platform_id);
        $c->stash->{platform} = $pt->value;
    }

    my $mt = $c->model('DB::ControlledVocab')->find({ category => 'MaterialType',
                                                      value    => 'RNA', });

    unless ( $mt ) {
        $c->flash->{error} = qq{Error: MaterialType "RNA" not found in database.};
        $c->res->redirect( $c->uri_for('/default') );
        $c->detach();        
    }

    # Note that visits only show up on the report page if they've been
    # assigned a nominal timepoint. Such timepoints are how we know
    # that a sample should have been taken.

    # Prefetch here is absolutely *required* for scalability when
    # handling hundreds of patient visits.
    my %visit_attrs = ( order_by => 'trial_id',
                        distinct => 1,
                        prefetch => { samples => 'cell_type_id' }, );

    # No join on material type here!
    my %visit_query = ( nominal_timepoint_id => { '!=' => undef } );

    # Perversely, this prefetch actually *adds* time to the query. I'm
    # not sure why, since we're running a query very much like this in
    # the loop. Presumably the prefetch here isn't helping there,
    # possibly because there we have to join instead of prefetching?
 
#     if ( defined $platform_id ) {

#         # N.B. in an ideal world we'd also prefetch samples =>
#         # cell_type_id but that's getting a bit too complicated for
#         # DBIx::Class::ResultSet.

#          $visit_attrs{ prefetch } = {
#              samples => {
#                  channels => {
#                      assay_id => {
#                          assay_batch_id => 'platform_id' } } } };

#         # N.B. you *don't* want a join here on platform_id, otherwise
#         # only those visits with at least one hyb on the platform will
#         # be represented.
#     }

    # Retrieve the visits with as much extra prefetched info as we can.
    my @visits = $cv->search_related('studies')
                    ->search_related('patient_id')
                    ->search_related('visits', \%visit_query, \%visit_attrs,);

    # Simple id => value map, used to avoid a looped database query.
    my %celltype_map =  map { $_->id() => $_->value() }
                       $c->model('DB::ControlledVocab')
                         ->search({ category => 'CellType',
                                    value    => {'not_in' => [ 'unknown', 'none' ] } } );

    # Scores to determine what constitutes a "complete" set of assays.
    my %channelval = (
        'biotin' => 1,
        'Cy3'    => 0.5,
        'Cy5'    => 0.5,
    );

    # This loop is what actually takes the time, I think.
    my @data;
    foreach my $visit ( @visits ) {

        my %sample;

        # MaterialType filter only once we've registered the visit.
        my @rnas = $visit->samples({ material_type_id => $mt->id() });

        # Assumes only one RNA sample per cell type per visit.
        RNA:
        foreach my $rna ( @rnas ) {

            # Hash lookup to save running a database query in this
            # loop (saves about .5s per query).
            my $celltype = $celltype_map{ $rna->get_column('cell_type_id') } or next RNA;
            my $count    = 0;

            # If platform has been specified, use a join to filter our
            # channels. The prefetch system above doesn't seem to help
            # with the speed of this, but I'd regard it as a potential
            # target for optimisation in future.
            my @channels;
            if ( defined $platform_id ) {
                @channels = $rna->channels(
                    { 'platform_id.id' => $platform_id },
                    { join => {
                        assay_id => {
                            assay_batch_id => 'platform_id' } } },
                );
            }
            else {
                @channels = $rna->channels();
            }
            
            # Record the number of whole assays for a given sample cell type.
            foreach my $channel ( @channels ) {
                if ( my $val = $channelval{ $channel->label_id()->value() } ) {
                    $count += $val;
                }
            }
            $sample{$celltype} = $count;
        }

        # %sample can be empty.
        push @data, {
            visit   => $visit,
            sample  => \%sample,
        };

    }
    
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
    push @{ $c->stash->{breadcrumbs} }, {
        path  => '/sample/assay_report',
        label => 'Assay reports',
    }, {
        path  => $c->req()->uri(),
        label => 'Assay list',
    };

    $c->stash->{celltypes} = [ sort values %celltype_map ];
    $c->stash->{visitdata} = \@data;
}

sub switch_channels : Local {

    my ( $self, $c, $object_id ) = @_;

    # Confirm we have privileges to be here.
    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    # Retrieve our sample.
    my $object = $c->model('DB::Sample')->find({ id => $object_id });
    if ( ! $object ) {
        $c->flash->{error} = "No such sample!";
        $c->res->redirect( $c->uri_for('/sample/list') );
        $c->detach();
    }

    my @channels = $object->channels();

    # We can't switch if there aren't two and only two channels.
    if ( scalar @channels != 2 ) {
        $c->flash->{error} = "Sample not linked to just two channels!";
        $c->res->redirect( $c->uri_for('/sample/view', $object_id) );
        $c->detach();        
    }

    # Actually switch the channels.
    my $label1 = $channels[0]->label_id();
    $channels[0]->set_column( 'label_id' => $channels[1]->label_id()->id() );
    $channels[1]->set_column( 'label_id' => $label1->id() );
    foreach my $ch ( @channels ) { $ch->update() }

    # Redirect back to the sample view.
    $c->res->redirect( $c->uri_for('/sample/view', $object_id) );
    $c->detach();
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
