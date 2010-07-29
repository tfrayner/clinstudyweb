package ClinStudy::ORM;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:liMGy5aUIjW0p6MU46BPRg

__PACKAGE__->load_components("Schema::Journal");
__PACKAGE__->journal_user( [ 'ClinStudy::ORM::User', {'foreign.id' => 'self.user_id'} ] );

# You can replace this text with custom content, and it will be preserved on regeneration

use 5.008001;

our $VERSION = 0.1;

=head1 NAME

ClinStudy::ORM - An object-relational mapping layer used by the
ClinStudy::Web application to interact with its database.

=head1 SYNOPSIS

    use ClinStudy::ORM;
    my $schema = ClinStudy::ORM->connect( $dsn, $user, $pass, $args );
    my @patients = $schema->resultset('Patient');

=head1 DESCRIPTION

The ClinStudy::ORM ORM is generated automatically from the SQL schema
used to create the underlying ClinWeb database. See
L<DBIx::Class::Schema::Loader> module documentation for details.

=head1 SEE ALSO

L<ClinStudy::Web>, L<DBIx::Class>

=head1 AUTHOR

Tim Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
