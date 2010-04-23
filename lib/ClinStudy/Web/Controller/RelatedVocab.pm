package ClinStudy::Web::Controller::RelatedVocab;

use strict;
use warnings;

use parent 'ClinStudy::Web::Controller::FormFuBase';

=head1 NAME

ClinStudy::Web::Controller::RelatedVocab - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'DB::RelatedVocab' );
    $self->my_sort_field( 'relationship_id' );
    $self->my_container_namespace( 'controlledvocab' );

    return $self;
}

# FIXME ideally this would be deleted in favour of a more sane
# approach to container_namespace allowing for underscores in the
# designated containers.
sub my_container_class {

    my ( $self ) = @_;

    return('DB::ControlledVocab', 'controlled_vocab_id', 'controlledvocab');

}

sub _set_my_editing_message {

    my ( $self, $c, $object, $action, $flash ) = @_;

    $flash ||= 'flash';
    $c->$flash->{message}
        = sprintf("%s %s %s",
                  $action,
                  ( $object->relationship_id ? $object->relationship_id->value : q{} ),
                  'relationship',);
}

sub set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    my $namespace  = $self->action_namespace($c);
    my $sort_field = $self->my_sort_field();

    $c->flash->{message}
        = sprintf(qq{Deleted %s relationship},
                  $object->relationship_id->value );
}

=head2 add_to_controlled_vocab

=cut

sub add_to_controlled_vocab : Local {
    my $self = shift;
    $self->SUPER::add_to_container( @_ );
}

=head1 AUTHOR

tfr23

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
