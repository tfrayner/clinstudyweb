package ClinStudy::ORM::Drug;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("drug");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "dose",
  {
    data_type => "DECIMAL",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "dose_unit_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "dose_freq_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "dose_duration",
  {
    data_type => "DECIMAL",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
  "duration_unit_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "dose_regime",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "type_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "locale_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "visit_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "prior_treatment_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "hospitalisation_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("drug_visit_id", ["name", "visit_id"]);
__PACKAGE__->add_unique_constraint("drug_prior_treatment_id", ["name", "prior_treatment_id"]);
__PACKAGE__->add_unique_constraint("drug_hospitalisation_id", ["name", "hospitalisation_id"]);
__PACKAGE__->belongs_to(
  "dose_unit_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "dose_unit_id" },
);
__PACKAGE__->belongs_to(
  "dose_freq_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "dose_freq_id" },
);
__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);
__PACKAGE__->belongs_to(
  "locale_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "locale_id" },
);
__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });
__PACKAGE__->belongs_to(
  "prior_treatment_id",
  "ClinStudy::ORM::PriorTreatment",
  { id => "prior_treatment_id" },
);
__PACKAGE__->belongs_to(
  "hospitalisation_id",
  "ClinStudy::ORM::Hospitalisation",
  { id => "hospitalisation_id" },
);
__PACKAGE__->belongs_to(
  "duration_unit_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "duration_unit_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-09 15:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+Ph0NfSEgjyQ+mAwuDB+oA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
