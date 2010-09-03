package CIMR::BloodDB::ExpCtHaematolConcat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

CIMR::BloodDB::ExpCtHaematolConcat

=cut

__PACKAGE__->table("exp_ct_haematol_concat");

=head1 ACCESSORS

=head2 hospno

  data_type: 'char'
  is_nullable: 1
  size: 24

=head2 resdate

  data_type: 'timestamp'
  is_nullable: 1

=head2 restime

  data_type: 'timestamp'
  is_nullable: 1

=head2 aptt

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 deletedyn

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 eosinophils

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 esr

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 haemoglobin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 inr

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 lymphocytes

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 mcv

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 neutrophils

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 plts

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 pt

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 rowinsertdatetime

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 specimenid

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 wbc

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 table_id

  data_type: 'integer'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "hospno",
  { data_type => "char", is_nullable => 1, size => 24 },
  "resdate",
  { data_type => "timestamp", is_nullable => 1 },
  "restime",
  { data_type => "timestamp", is_nullable => 1 },
  "aptt",
  { data_type => "char", is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", is_nullable => 1, size => 510 },
  "eosinophils",
  { data_type => "char", is_nullable => 1, size => 510 },
  "esr",
  { data_type => "char", is_nullable => 1, size => 510 },
  "haemoglobin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "inr",
  { data_type => "char", is_nullable => 1, size => 510 },
  "lymphocytes",
  { data_type => "char", is_nullable => 1, size => 510 },
  "mcv",
  { data_type => "char", is_nullable => 1, size => 510 },
  "neutrophils",
  { data_type => "char", is_nullable => 1, size => 510 },
  "plts",
  { data_type => "char", is_nullable => 1, size => 510 },
  "pt",
  { data_type => "char", is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "wbc",
  { data_type => "char", is_nullable => 1, size => 510 },
  "table_id",
  { data_type => "integer", is_nullable => 0, size => 20 },
);
__PACKAGE__->set_primary_key("table_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-09-03 14:22:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UgtRBnPV+tZbym5+bmtx6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
