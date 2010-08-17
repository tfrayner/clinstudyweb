package CIMR::BloodDB::CtBiochemistry;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ct_biochemistry");
__PACKAGE__->add_columns(
  "table_id",
  {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
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
  "resname",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 100 },
  "resvalue",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 150 },
);
__PACKAGE__->set_primary_key("table_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-09 10:32:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RlsRI4jKn/0mgdxUwjweqA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
