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
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("unique_treatment", ["patient_id", "type_id"]);
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
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-06-03 15:45:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rfI8QUUr2F/kpesm0EUccA


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->has_many(
  "drugs",
  "ClinStudy::ORM::Drug",
  { "foreign.prior_treatment_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

1;
