package ClinStudy::ORM::PriorObservation;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("prior_observation");
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
  "date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("id");
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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-06-04 14:15:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:al2feaq8uJZriTi81f2Vpg


# You can replace this text with custom content, and it will be preserved on regeneration
1;