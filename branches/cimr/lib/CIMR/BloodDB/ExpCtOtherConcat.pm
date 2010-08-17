package CIMR::BloodDB::ExpCtOtherConcat;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("exp_ct_other_concat");
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
  "afp",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "alpha1antitrypsingenotype",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "ana_elisa_ena_dna_centromere",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "anca_if",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "anca_mp0",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "anca_pr3",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "antidna",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "antilkm",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "antimitochondrial",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "antismoothmuscle",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "ca19point9",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "caeruloplasmin",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd19percent",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd19total",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd3percent",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd3total",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd4percent",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd4total",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd56total",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd8percent",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cd8total",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "complementc3",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "complementc4",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "cryoglobulin",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "iga",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "igg",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "igm",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "labcodeid",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "lymphocytecount",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "rheumatoidfactor",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", default_value => undef, is_nullable => 1, size => 510 },
  "whitebloodcellcount",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LTn3beIntH99jMAUsvWhjw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
