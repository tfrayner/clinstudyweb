package ClinStudy::ORM::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::UserRole

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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("user_role", ["user_id", "role_id"]);

=head1 RELATIONS

=head2 user_id

Type: belongs_to

Related object: L<ClinStudy::ORM::User>

=cut

__PACKAGE__->belongs_to("user_id", "ClinStudy::ORM::User", { id => "user_id" });

=head2 role_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Role>

=cut

__PACKAGE__->belongs_to("role_id", "ClinStudy::ORM::Role", { id => "role_id" });


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 21:47:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wZQB2BuVTMPkRvfjR6lpbw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
