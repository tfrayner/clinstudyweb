package ClinStudy::ORM::Sample;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("sample");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 31,
  },
  "visit_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "cell_type_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "material_type_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "num_aliquots",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 6 },
  "freezer_location",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "freezer_box",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 31,
  },
  "box_slot",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 31,
  },
  "concentration",
  {
    data_type => "DECIMAL",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "purity",
  {
    data_type => "DECIMAL",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "quality_score_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.sample_id" => "self.id" },
);
__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });
__PACKAGE__->belongs_to(
  "cell_type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "cell_type_id" },
);
__PACKAGE__->belongs_to(
  "material_type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "material_type_id" },
);
__PACKAGE__->belongs_to(
  "quality_score_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "quality_score_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:obWIRLEAXHA2OHGfs31x5A


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.sample_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

__PACKAGE__->many_to_many(
    "assays" => "channels", "assay_id"
);

1;
