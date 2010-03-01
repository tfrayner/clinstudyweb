package ClinStudy::ORM::AdverseEvent;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("adverse_event");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "type",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "start_date",
  { data_type => "DATE", default_value => undef, is_nullable => 0, size => 10 },
  "end_date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "severity_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "action_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "outcome_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "trial_related_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);
__PACKAGE__->belongs_to(
  "severity_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "severity_id" },
);
__PACKAGE__->belongs_to(
  "action_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "action_id" },
);
__PACKAGE__->belongs_to(
  "outcome_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "outcome_id" },
);
__PACKAGE__->belongs_to(
  "trial_related_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "trial_related_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/vOOKSQYReTGdTJTcSDrSA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
