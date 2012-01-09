use utf8;
package CIMR::BloodDB::ExpCtOtherConcat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CIMR::BloodDB::ExpCtOtherConcat

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<exp_ct_other_concat>

=cut

__PACKAGE__->table("exp_ct_other_concat");

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

=head2 afp

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 alpha1antitrypsingenotype

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ana_elisa_ena_dna_centromere

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 anca_if

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 anca_mp0

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 anca_pr3

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 antidna

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 antilkm

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 antimitochondrial

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 antismoothmuscle

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ca19point9

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 caeruloplasmin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd19percent

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd19total

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd3percent

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd3total

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd4percent

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd4total

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd56total

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd8percent

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cd8total

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 complementc3

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 complementc4

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cryoglobulin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 deletedyn

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 iga

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 igg

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 igm

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 labcodeid

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 lymphocytecount

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 rheumatoidfactor

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

=head2 whitebloodcellcount

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
  "afp",
  { data_type => "char", is_nullable => 1, size => 510 },
  "alpha1antitrypsingenotype",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ana_elisa_ena_dna_centromere",
  { data_type => "char", is_nullable => 1, size => 510 },
  "anca_if",
  { data_type => "char", is_nullable => 1, size => 510 },
  "anca_mp0",
  { data_type => "char", is_nullable => 1, size => 510 },
  "anca_pr3",
  { data_type => "char", is_nullable => 1, size => 510 },
  "antidna",
  { data_type => "char", is_nullable => 1, size => 510 },
  "antilkm",
  { data_type => "char", is_nullable => 1, size => 510 },
  "antimitochondrial",
  { data_type => "char", is_nullable => 1, size => 510 },
  "antismoothmuscle",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ca19point9",
  { data_type => "char", is_nullable => 1, size => 510 },
  "caeruloplasmin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd19percent",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd19total",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd3percent",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd3total",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd4percent",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd4total",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd56total",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd8percent",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cd8total",
  { data_type => "char", is_nullable => 1, size => 510 },
  "complementc3",
  { data_type => "char", is_nullable => 1, size => 510 },
  "complementc4",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cryoglobulin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", is_nullable => 1, size => 510 },
  "iga",
  { data_type => "char", is_nullable => 1, size => 510 },
  "igg",
  { data_type => "char", is_nullable => 1, size => 510 },
  "igm",
  { data_type => "char", is_nullable => 1, size => 510 },
  "labcodeid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "lymphocytecount",
  { data_type => "char", is_nullable => 1, size => 510 },
  "rheumatoidfactor",
  { data_type => "char", is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "whitebloodcellcount",
  { data_type => "char", is_nullable => 1, size => 510 },
  "table_id",
  { data_type => "integer", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</table_id>

=back

=cut

__PACKAGE__->set_primary_key("table_id");


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-11-21 13:51:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ya1ULp+7Jmv5rEyL6wxlWw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
