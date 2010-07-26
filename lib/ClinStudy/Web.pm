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

package ClinStudy::Web;

use strict;
use warnings;

use Scalar::Util qw(blessed);
use Carp;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from the Config::YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/ConfigLoader
                Static::Simple

                Session
                Session::State::Cookie
                Session::Store::FastMmap

                Authentication
                Authorization::Roles
                Authorization::ACL
               /;

use 5.008001;

our $VERSION = '0.01';

#################
# Configuration #
#################
#
# Note that settings in clinstudy_web.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name    => 'ClinStudy::Web',
    session => { flash_to_stash => 1,
                 expires        => 3600, },
    authentication => {  
        default_realm => 'clindb',
        realms => {
            clindb => {
                credential => {
                    class          => 'Password',
                    password_field => 'password',
                    password_type  => 'hashed',
                },
                store => {
                    class         => 'DBIx::Class',
                    user_class    => 'DB::User',
                    id_field      => 'id',
                    role_relation => 'roles',
                    role_field    => 'rolename',
                }
            },
        }
    },
    'Controller::HTML::FormFu' => {
        model_stash => {
            schema => 'DB',
        },
    },
);

# Start the application.
__PACKAGE__->setup();

##################
# Access Control #
##################

# Protected areas containing patient data. Edit and delete actions
# will be separately constrained to e.g. editor and admin roles
# respectively.
__PACKAGE__->allow_access_if( '/patient', [ qw( user ) ] );
__PACKAGE__->deny_access( '/patient' );

__PACKAGE__->allow_access_if( '/comorbidity', [ qw( user ) ] );
__PACKAGE__->deny_access( '/comorbidity' );

__PACKAGE__->allow_access_if( '/diagnosis', [ qw( user ) ] );
__PACKAGE__->deny_access( '/diagnosis' );

__PACKAGE__->allow_access_if( '/diseaseevent', [ qw( user ) ] );
__PACKAGE__->deny_access( '/diseaseevent' );

__PACKAGE__->allow_access_if( '/visit',   [ qw( user ) ] );
__PACKAGE__->deny_access( '/visit' );

__PACKAGE__->allow_access_if( '/hospitalisation', [ qw( user ) ] );
__PACKAGE__->deny_access( '/hospitalisation' );

__PACKAGE__->allow_access_if( '/testresult', [ qw( user ) ] );
__PACKAGE__->deny_access( '/testresult' );

__PACKAGE__->allow_access_if( '/drug', [ qw( user ) ] );
__PACKAGE__->deny_access( '/drug' );

__PACKAGE__->allow_access_if( '/adverseevent', [ qw( user ) ] );
__PACKAGE__->deny_access( '/adverseevent' );

__PACKAGE__->allow_access_if( '/priorobservation', [ qw( user ) ] );
__PACKAGE__->deny_access( '/priorobservation' );

__PACKAGE__->allow_access_if( '/priortreatment', [ qw( user ) ] );
__PACKAGE__->deny_access( '/priortreatment' );

__PACKAGE__->allow_access_if( '/study', [ qw( user ) ] );
__PACKAGE__->deny_access( '/study' );

__PACKAGE__->allow_access_if( '/riskfactor', [ qw( user ) ] );
__PACKAGE__->deny_access( '/riskfactor' );

__PACKAGE__->allow_access_if( '/sample', [ qw( user ) ] );
__PACKAGE__->deny_access( '/sample' );

__PACKAGE__->allow_access_if( '/transplant', [ qw( user ) ] );
__PACKAGE__->deny_access( '/transplant' );

__PACKAGE__->allow_access_if( '/assay', [ qw( user ) ] );
__PACKAGE__->deny_access( '/assay' );

__PACKAGE__->allow_access_if( '/assayqcvalue', [ qw( user ) ] );
__PACKAGE__->deny_access( '/assayqcvalue' );

# These are currently admin-only.
__PACKAGE__->allow_access_if( '/controlledvocab',   [ qw( admin ) ] );
__PACKAGE__->deny_access( '/controlledvocab' );

__PACKAGE__->allow_access_if( '/relatedvocab',   [ qw( admin ) ] );
__PACKAGE__->deny_access( '/relatedvocab' );

__PACKAGE__->allow_access_if( '/emergentgroup',   [ qw( admin ) ] );
__PACKAGE__->deny_access( '/emergentgroup' );

__PACKAGE__->allow_access_if( '/priorgroup',   [ qw( admin ) ] );
__PACKAGE__->deny_access( '/priorgroup' );

# This is currently admin-only (and is likely to stay that way; it's
# too easy to break things otherwise).
__PACKAGE__->allow_access_if( '/test',   [ qw( admin ) ] );
__PACKAGE__->deny_access( '/test' );

# User tables require some special treatment. Admin users are
# access-all-areas.
__PACKAGE__->allow_access_if( '/user',   [ qw( admin ) ] );

# Everyone needs to be able to add, modify or reset the password for
# their own entry (the controller actions further check that the
# logged-in user and the user to be changed are one and the
# same). Note that currently /user/reset is not really used other than
# by admin.
__PACKAGE__->allow_access( '/user/add' );
__PACKAGE__->allow_access( '/user/modify' );
__PACKAGE__->allow_access( '/user/reset' );
__PACKAGE__->deny_access( '/user' );

# These should never be accessed directly.
__PACKAGE__->deny_access( '/formfubase' );
__PACKAGE__->deny_access( '/patientlinkedobject' );
__PACKAGE__->deny_access( '/hospitalisationlinkedobject' );
__PACKAGE__->deny_access( '/visitlinkedobject' );

# Areas to which access is always granted.
__PACKAGE__->allow_access( '/default' );
__PACKAGE__->allow_access( '/index' );
__PACKAGE__->allow_access( '/login' );

# The REST API uses its own authentication based on password.
__PACKAGE__->allow_access( '/rest' );

# A convenience method to check that there are no objects linked to a
# given DBIx::Class::Row via non-cascading_delete
# relationships. Returns undef if everything is okay, otherwise a
# string listing the relationships suitable for passing to the user.
sub check_model_relationships {

    my ( $c, $row ) = @_;
    
    my $source = $row->result_source();
    my %is_linked;
    foreach my $rel ( $source->relationships() ) {

        # Skip the relationship if it has no cascade_delete
        # attribute, or if it's set to 1.
        my $attrs = $source->relationship_info( $rel )->{attrs};
        next if ( ! exists $attrs->{cascade_delete} || $attrs->{cascade_delete} );

        my @items = $row->$rel;
        if ( my $count = scalar @items ) {
            $is_linked{ $rel } = $count;
        }
    }

    my $message;
    if ( scalar grep { defined $_ } values %is_linked ) {
        my @items;
        foreach my $rel ( sort keys %is_linked ) {
            my $count = $is_linked{ $rel };
            $rel =~ s/_/ /g;
            push @items, "$count $rel";
        }
        $message = join(', ', @items );
    }

    return $message;
}

# A dispatch table and a couple of wrapper methods to help with
# routing through drug and test_result from various possible sources.
{
    my %dispatch = (
        'PriorTreatment'  => { 'id_method' => 'prior_treatment_id',
                               'redirect'  => '/priortreatment/view', },
        'Visit'           => { 'id_method' => 'visit_id',
                               'redirect'  => '/visit/view', },
        'Hospitalisation' => { 'id_method' => 'hospitalisation_id',
                               'redirect'  => '/hospitalisation/view', },
    );

    # Quick rejig of the dispatch table.
    my %redirect_dispatch =
        map { $_->{'id_method'} => $_->{'redirect'} }
            values %dispatch;

    sub _redirect_from_classname {

        my ( $c, $fullclass ) = @_;

        my ( $class ) = ( $fullclass =~ m/ ([^\:]+) \z/xms );

        unless ( $class && $dispatch{ $class } ) {
            return;
        }
        my $id_method = $dispatch{ $class }{ 'id_method' };

        # N.B. FIXME this is broken; should probably link to a listing
        # rather than a view. Not used at the moment though...
        my $redirect  = $c->uri_for( $dispatch{ $class }{ 'redirect' } );
        
        return( $id_method, $redirect );
    }

    sub _redirect_from_dbobj {

        my ( $c, $dbobj ) = @_;

        my ( $id_method, $redirect );

        REDIRECT:
        foreach my $method ( keys %redirect_dispatch ) {
            if ( UNIVERSAL::can($dbobj, $method) && defined( $dbobj->$method ) ) {
                $id_method = $method;
                $redirect  = $c->uri_for( $redirect_dispatch{ $method }, $dbobj->$method->id );
                last REDIRECT;
            }
        }

        # TestResult may have a parent TestResult, which is the preferred redirect.
        if ( blessed( $dbobj ) =~ /::TestResult \z/xms ) {
            my @parents = $dbobj->parent_test_results();
            if ( scalar @parents ){

                # We just use the first parent result; this is one of
                # the hassles of multiple inheritance :-(
                $redirect = $c->uri_for( '/testresult/view', $parents[0]->id() );
            }
        }

        return( $id_method, $redirect );
    }
}

sub date_today {

    my ( $c ) = @_;

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime(time);
    $mon++;           # localtime starts months from 0
    $year += 1900;    # localtime starts years from 100

    return sprintf( "%04d-%02d-%02d %02d:%02d:%02d",
                    $year, $mon, $mday, $hour, $min, $sec );
}

sub recalculate_aggregates {

    my ( $c, $container, $study_type ) = @_;

    # We need some better error handling here and in the test calculators.
    my $calcs = $c->config->{'test_calculators'};
    if ( my $calcname = $calcs->{ $study_type->value() } ) {
        my $calcclass = "ClinStudy::Web::TestCalc::$calcname";
        eval "require $calcclass";
        if ( $@ ) {
            confess("Error loading $calcclass: $@");
        }
        my $calc = $calcclass->new();
        eval { $calc->calculate( $container, $c->model('DB')->schema(), $c ) };
        if ( $@ ) {

            # Not a crisis, but we need to record such things, ideally
            # without disturbing the user. Note that not all
            # containers will necessarily have calculable data, so
            # this is likely to happen often. It's not really an error.
            my $contname = $container->result_source->source_name();
            my @pks      = $container->result_source->primary_columns();
            my $id       = join(":", map { $container->$_ } @pks );
            $c->log->info( "Unable to calculate $calcname for $contname $id: $@" );
        }
    }
}

sub _set_journal_changeset_attrs {

    my ( $c ) = @_;

    # Since all our database updates are (or should be) preceded by
    # this call, we check here whether the database has been set to
    # read-only or not.
    if ( $c->config->{WebIsReadOnly} ) {
        $c->stash->{error} = 'Sorry, the database is currently in read-only mode. '
                           . 'Please contact your database administrator for details.';
        $c->detach( '/access_denied' );
    }

    if ( my $user = $c->user() ) {
        $c->model->result_source->schema->changeset_user( $user->id() );
    }
    if ( my $session_id = $c->sessionid() ) {
        $c->model->result_source->schema->changeset_session( $session_id );
    }

    return;
}

sub form_values_to_database {

    my ( $c, $object, $form ) = @_;

    $c->_set_journal_changeset_attrs();

    $c->model->result_source->schema->txn_do(
        sub {
            $form->model->update( $object );
        }
    );

    return;
}

sub update_database_object {

    my ( $c, $object, $attrs ) = @_;

    $c->_set_journal_changeset_attrs();

    $c->model->result_source->schema->txn_do(
        sub {
            if ( $attrs && ref $attrs eq 'HASH' ) {
                while ( my ( $key, $value ) = each %$attrs ) {
                    $object->set_column( $key, $value );
                }
            }

            # Call update anyway; $attrs is optional.
            $object->update();
        }
    );
    
    return;
}

sub delete_database_object {

    my ( $c, $object ) = @_;

    $c->_set_journal_changeset_attrs();

    $c->model->result_source->schema->txn_do(
        sub {
            $object->delete();
        }
    );
    
    return;
}

=head1 NAME

ClinStudy::Web - Catalyst based application

=head1 SYNOPSIS

    script/clinstudyweb_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<ClinStudy::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
