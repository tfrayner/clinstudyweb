package ClinStudy::ORM::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "role_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("user_id", "role_id");
__PACKAGE__->belongs_to("user_id", "ClinStudy::ORM::User", { id => "user_id" });
__PACKAGE__->belongs_to("role_id", "ClinStudy::ORM::Role", { id => "role_id" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X1itZ2r6fsjljv9TANEa3A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
