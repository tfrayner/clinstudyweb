use utf8;
package ClinStudy::ORM::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::UserRole

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_role>

=cut

__PACKAGE__->table("user_role");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_id>

=over 4

=item * L</user_id>

=item * L</role_id>

=back

=cut

__PACKAGE__->add_unique_constraint("user_id", ["user_id", "role_id"]);

=head1 RELATIONS

=head2 role_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Role>

=cut

__PACKAGE__->belongs_to("role_id", "ClinStudy::ORM::Role", { id => "role_id" });

=head2 user_id

Type: belongs_to

Related object: L<ClinStudy::ORM::User>

=cut

__PACKAGE__->belongs_to("user_id", "ClinStudy::ORM::User", { id => "user_id" });


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0EgoleQRmMoXFnAx53w3gA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
