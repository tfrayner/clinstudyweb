package ClinStudy::ORM::PriorTreatment;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("prior_treatment");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "type_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "value",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "duration",
  {
    data_type => "DECIMAL",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "duration_unit_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "date",
  { data_type => "DATE", default_value => undef, is_nullable => 0, size => 10 },
  "nominal_timepoint_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "days_uncertainty",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 6 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "unique_treatment",
  ["patient_id", "type_id", "date", "days_uncertainty"],
);
__PACKAGE__->has_many(
  "drugs",
  "ClinStudy::ORM::Drug",
  { "foreign.prior_treatment_id" => "self.id" },
);
__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);
__PACKAGE__->belongs_to(
  "nominal_timepoint_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "nominal_timepoint_id" },
);
__PACKAGE__->belongs_to(
  "duration_unit_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "duration_unit_id" },
);
__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-05-17 14:43:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sXYEAQweNsIqQatYmF1Xpw


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->has_many(
  "drugs",
  "ClinStudy::ORM::Drug",
  { "foreign.prior_treatment_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

1;
