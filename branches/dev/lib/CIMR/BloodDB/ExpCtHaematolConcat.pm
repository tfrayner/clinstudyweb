package CIMR::BloodDB::ExpCtHaematolConcat;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("exp_ct_haematol_concat");
__PACKAGE__->add_columns(
  "hospno",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 24 },
  "resdate",
  {
    data_type => "timestamp",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "restime",
  {
    data_type => "timestamp",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "aptt",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "eosinophils",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "esr",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "haemoglobin",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "inr",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "lymphocytes",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "mcv",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "neutrophils",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "plts",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "pt",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "wbc",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "table_id",
  {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
);
__PACKAGE__->set_primary_key("table_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-09 10:32:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:05TpvdPqweul4+UA/DLbWw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
