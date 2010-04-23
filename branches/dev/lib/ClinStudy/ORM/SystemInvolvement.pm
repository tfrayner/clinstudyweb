package ClinStudy::ORM::SystemInvolvement;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("system_involvement");
__PACKAGE__->add_columns(
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "type_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("patient_id", "type_id");
__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);
__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vkAtpZkotzXO/hNEH78Z5Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
