package ClinStudy::ORM::Diagnosis;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("diagnosis");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "condition_name_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "confidence_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
  "previous_episodes",
  { data_type => "TINYINT", default_value => undef, is_nullable => 1, size => 1 },
  "previous_course_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "previous_duration_months",
  {
    data_type => "DECIMAL",
    default_value => undef,
    is_nullable => 1,
    size => 12,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);
__PACKAGE__->belongs_to(
  "condition_name_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "condition_name_id" },
);
__PACKAGE__->belongs_to(
  "confidence_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "confidence_id" },
);
__PACKAGE__->belongs_to(
  "previous_course_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "previous_course_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-10-29 19:08:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y+wT6A0DyRLGZO7Q7yksJg


# You can replace this text with custom content, and it will be preserved on regeneration

1;
