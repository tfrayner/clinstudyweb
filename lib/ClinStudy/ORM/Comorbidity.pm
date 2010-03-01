package ClinStudy::ORM::Comorbidity;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("comorbidity");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "condition_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "date",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-10-29 19:08:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GuUh0uK32moD2QeI3hCICw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
