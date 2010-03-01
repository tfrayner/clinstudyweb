package CIMR::BloodDB::ExpCtVirologyConcat;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("exp_ct_virology_concat");
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
  "anti_hbs_post_vaccination",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cmv_igg",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cmv_latex",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cmv_pcr",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "ebv_vca_igg",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "hepbsag",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "hepc",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "hiv",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "hsv",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "labcodeid",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "toxo",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "vzv",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rRtY2uwGZ0Z3NTOd6tXpqA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
