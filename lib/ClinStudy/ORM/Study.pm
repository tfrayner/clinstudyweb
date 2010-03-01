package ClinStudy::ORM::Study;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("study");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "type_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "external_id",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-12-03 14:34:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L+4DIokqd/lvPuF6X/60bA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
