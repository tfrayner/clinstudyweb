package ClinStudy::ORM::EmergentGroup;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("emergent_group");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "basis_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "type_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name", ["name", "type_id"]);
__PACKAGE__->belongs_to(
  "basis_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "basis_id" },
);
__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);
__PACKAGE__->has_many(
  "visit_emergent_groups",
  "ClinStudy::ORM::VisitEmergentGroup",
  { "foreign.emergent_group_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oabIxkvnqzSLH8peMpTHTA


# You can replace this text with custom content, and it will be preserved on regeneration

# This cascading delete is only allowed from the visit, not the
# group.
__PACKAGE__->has_many(
  "visit_emergent_groups",
  "ClinStudy::ORM::VisitEmergentGroup",
  { "foreign.emergent_group_id" => "self.id" },
  { "cascade_delete"   => 0 },
);

# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:
__PACKAGE__->many_to_many(
    "visits" => "visit_emergent_groups", "visit_id",
  { "cascade_delete"   => 0 },
);

1;
