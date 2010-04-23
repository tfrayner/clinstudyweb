package ClinStudy::ORM::GraftFailure;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("graft_failure");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "date",
  { data_type => "DATE", default_value => undef, is_nullable => 0, size => 10 },
  "reason",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "transplant_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("transplant_id", ["transplant_id"]);
__PACKAGE__->belongs_to(
  "transplant_id",
  "ClinStudy::ORM::Transplant",
  { id => "transplant_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rki/UYQQjtCRTDw+Yytwnw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
