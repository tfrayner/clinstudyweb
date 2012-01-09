package Catalyst::Authentication::Credential::Raven;

use warnings;
use strict;

use UNIVERSAL::require;
use NEXT;

use base qw/Class::Accessor::Fast/;

BEGIN {
    __PACKAGE__->mk_accessors(qw/_config realm/);
}

=head1 NAME

Catalyst::Authentication::Credential::Raven - Raven authentication plugin for Catalyst

=head1 VERSION

Version 0.011a

=cut

our $VERSION = '0.011a';

=head1 SYNOPSIS

    # In your main Catalyst application module, load plugins. The
    # Roles and ACL plugins are optional:
    use parent qw/Catalyst/;
    use Catalyst qw/
        ConfigLoader
        Authentication
        Authorization::Roles
        Authorization::ACL

        Session
        Session::State::Cookie
        Session::Store::FastMmap
    /;

    # In your application config file, set up the Authentication
    # plugin to use Raven:
    ---
    authentication:

        # Multiple authentication realms can be used in parallel; for
        # clarity we only show the raven realm here.
        default_realm: raven
        realms:
            raven:
                credential:
                    class: Raven

                    # agent can contain any parameter understood by 
                    # Ucam::WebAuth::CGIAA->new() [except do_session]
                    # and must contain hostname.
                    agent:
                        description: Test Raven-authenticated DB
                        hostname:    your.domain.name.here
                        key_dir:     /where/you/store/your/key/files/

                    # auth can contain any parameter understood by 
                    # Ucam::WebAuth::CGIAA->authenticate().
                    auth:
                        interact: yes

                    # store can be used to implement a local access
                    # list. Use Catalyst::Authentication::Store::Null
                    # as the class if this level of complexity is not
                    # required.
                store:
                    class:         DBIx::Class
                    user_class:    DB::User
                    id_field:      id

                    # full ACL support is possible.
                    role_relation: roles
                    role_field:    rolename

    # In your Raven login controller, something like...
    sub raven_login : Global {

        my ( $self, $c ) = @_;

        # Authenticate the user.
        my $result = $c->authenticate( {}, 'raven' );

        if ( $c->user ) {

            # Check against a local access list, where applicable.
            if ( $c->user->in_storage ) {

                # User is in our local database. Access is granted,
                # but may still be restricted by any ACL system that
                # has been put in place.
                $c->flash->{message} = 'Successfully logged in via Raven.';
                $c->res->redirect($c->uri_for('/'));
                $c->detach();
            }
            else {

                # The user has been authenticated by Raven, but not
                # entered in our local access list. In this case we log
                # the user out to prevent further access.
                $c->logout;
                $c->flash->{error} = 'Local access has not been granted for this Raven user.';
                $c->res->redirect($c->uri_for('/'));
                $c->detach();
            }
        }

        return;
    }

    # Now ready to protect your resources:
    sub index : Private {
        my ( $self, $c ) = @_;

        # This works the magic:
        unless ( $c->user_exists() ) {
    	    $c->detach('/access_denied');
        }

        my $user = $c->user;
        $c->response->body("Test logged in as '$user'");
    }

    # Alternatively, the Authorization::ACL plugin can be used, either
    # application-wide or on a page by page basis, for example:
    sub edit : Private {
        my ( $self, $c ) = @_;

        if ( ! $c->check_any_user_role('editor') ) {
            $c->stash->{error} = 'You are not authorised to edit this record.';
            $c->detach( '/access_denied' );
        }

        my $user = $c->user;
        $c->response->body("Editing record as '$user'");
    }

=head1 METHODS

=cut

=head2 new

Object constructor. This is called automatically by the Catalyst
authentication plugin.

=cut

sub new {
    my ($class, $config, $app, $realm) = @_;

    # $config is the hashref pointed to by 'credential' in the
    # following Catalyst config scheme:
    #  authentication:
    #         realms:
    #             raven:
    #                 credential:
    #                     class: Raven
    #                     agent:
    #                         description: 'Test of Catalyst Raven plugin'
    #                         hostname:     localhost,
    #                     auth:
    #                         interact: yes

    my $self = { _config => $config };
    bless $self, $class;
    
    $self->realm($realm);
    
    return $self;
}

=head2 authenticate

This is the entry point, and will redirect to the Raven web login
service if no Raven ticket has been received, or will process a Raven
ticket and log in the specified principal as the Catalyst $c->user if
successful.

=cut

sub authenticate {
    my ($self, $c, $realm, $authinfo ) = @_;

    my $config = $self->_config();

    # Sadly, we cannot re-use our AA object as it seems to save state.
    # So we create a new one each time.

    my $aa_class = __PACKAGE__ . '::AA';
    my $aa = $aa_class->new(
			    %{$config->{agent}},
			    do_session => 0,
			    );

    $aa->wls_keys($aa->load_wls_keys()) unless $aa->wls_keys;

    my %auth_args = %{$config->{auth}} if $config->{auth};
    my $complete = $aa->authenticate($c, %auth_args);

    my $rstash = $c->stash->{raven_ticket} ||= {};
    $rstash->{complete} = $complete;
    if ($complete) {
	for my $m ( qw(status success msg issue expire id auth sso url) ) {
	    $rstash->{$m} = $aa->$m();
	}
	if ($aa->success) {

	    my $username = $aa->principal;
	    $rstash->{principal} = $username;
	    $c->log->info("raven authentication succeeded for '$username'");
	    return $self->_raven_process_user($c, $realm, $username);

	} else {
	    my $status = $aa->status;
	    my $msg    = $aa->msg;
	    $c->log->info("raven authentication failed, $status: '$msg'");
	}
    } else {
	$c->log->debug('raven authenticate did not complete') if $c->debug;
    }

    return;
}

sub _raven_process_user {
    my ($self, $c, $realm, $username) = @_;

    # $realm->store is instantiated from the 'store' part of the
    # following Catalyst config scheme:
    #  authentication:
    #         realms:
    #             raven:
    #                 credential:
    #                     class: Raven
    #                     agent:
    #                         description: 'Test of Catalyst Raven plugin'
    #                         hostname:     localhost,
    #                     auth:
    #                         interact: yes
    #                 store:
    #                     class:         DBIx::Class
    #                     user_class:    DB::User
    #                     id_field:      id
    #                     role_relation: roles
    #                     role_field:    rolename
    #
    # This can be used to e.g. point at a local database to find
    # authorized local users.
    my $store = $realm->store() || $c->default_auth_store;

    my $user = $store->find_user( { username => $username }, $c );
    if ($user) {
        $c->log->debug('Found user in store') if $c->debug;
    }
    else {

        # The fact that this is a dummy user needs to be detected by
        # the calling code if it's enforcing a local user list.
        $c->log->debug("Creating dummy user on the fly") if $c->debug;
        require Catalyst::Authentication::Store::Null;
	$user = Catalyst::Authentication::Store::Null->new()->find_user( {id => $username}, $c );

	# Make a copy of the ticket params
	$user->{raven_ticket} = { %{$c->stash->{raven_ticket}} };
    }

    $c->set_authenticated($user);
    return 1;
}

=head1 INTERNAL METHODS

=head2 setup

=cut

sub setup {
    my $c = shift;
    my $config = $c->config->{authentication}->{realms}->{raven} ||= {};

    $config->{user_class} ||= 'Catalyst::Authentication::User::Hash';
    $config->{user_class}->require;

    $c->NEXT::setup(@_);
}

=head1 AUTHOR

Michael Gray, C<< <mjg17 at cam.ac.uk> >>

=head1 BUGS

Please report any bugs or feature requests to
C<< <mjg17 at cam.ac.uk> >>.

=head1 ACKNOWLEDGEMENTS

L<Catalyst::Authentication::Credential::Hatena> and
L<Catalyst::Authentication::Credential::JugemKey> were useful 
starting points.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Michael Gray, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

package Catalyst::Authentication::Credential::Raven::AA;

use strict;
use warnings;

use base qw/Ucam::WebAuth::AA Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/context/);

# Our subclassing of Ucam::WebAuth::AA, providing shims to exchange
# the necessary info with the Catalyst framework.

sub authenticate {
    my $self = shift;
    my $c    = shift;

    $self->context($c);

    $self->location(undef);

    my $complete = $self->SUPER::authenticate(@_);

    $c->response->redirect($self->location) if $self->location;

    $self->context(undef); # to avoid circular references

    return $complete;
}

sub method {
    my $self = shift;
    return $self->context->request->method;
}

sub header {
    my $self = shift;
    my ($name, $value) = @_;

    if ($value) {
	return $self->context->response->header($name => $value);
    } else {
	return $self->context->request->header($name);
    }
}

sub querystring {
    my $self = shift;
    return $self->context->request->uri->query;
}

sub this_url {
    my $self = shift;
    return $self->context->request->uri;
}

# We don't need to supply a secure() method since it is only used
# if Ucam::WebAuth::AA is doing its own session cookie.

# Nicked from Ucam::WebAuth::CGIAA
sub load_wls_keys {

  my $self = shift;
  my $dir = $self->key_dir();

  Catalyst::Exception->throw("Failed to open key directory '$dir': $!") 
    unless opendir(KEYS,$dir);
  
  my %keys;
  
  my @files = readdir KEYS;
  foreach my $file (@files) {
    next unless $file =~ /^pubkey(\d+)$/ and -f "$dir/$file" and -r _ and -s _;
    my $keyno = $1;
    Catalyst::Exception->throw("Failed to open file for key '$file': $!") 
      unless open(KEY, "$dir/$file");    
    my $key = do { local( $/ ); <KEY> };
    close KEY;
    $keys{$keyno} = $key;
  }

  closedir KEYS;
  
  Catalyst::Exception->throw("No keys loaded!") unless %keys;
  
  return \%keys;

}

1; # End of Catalyst::Authentication::Credential::Raven
