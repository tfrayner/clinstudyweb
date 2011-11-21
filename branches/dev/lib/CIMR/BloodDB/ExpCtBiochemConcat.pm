use utf8;
package CIMR::BloodDB::ExpCtBiochemConcat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CIMR::BloodDB::ExpCtBiochemConcat

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<exp_ct_biochem_concat>

=cut

__PACKAGE__->table("exp_ct_biochem_concat");

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

=head2 acr

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 acth

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 albumin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 aldosterone

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 alp

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 alt

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 amylase

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 bicarb

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 bilirubin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 calcium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 chol_hdl_ratio

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cholesterol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ciclosporin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 corrected_calcium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cortisol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 creatinine

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 creatinineclearance

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 crp

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 deletedyn

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 dheasulphate

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ferritin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 fsh

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 gfr

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 glucose

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 growthhormone

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hba1c

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hdl_cholesterol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 igf

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 lactate

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ldl_cholesterol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 lh

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 lipase

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 magnesium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 oestradiol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 osmolality

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 phosphate

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 potassium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 prolactin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 pth

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 pthpmol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 red_cell_folate

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 renin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 rowinsertdatetime

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 saturation

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 serum_iron

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 sirolimus

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 sodium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 specimenid

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 t3

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 t4

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 tacrolimus

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 testosterone

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 total_ck

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 transferrin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 triglyceride

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 tsh

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urea

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 uric_acid

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urine5hiaa

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urinefreecortisol

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urineosmolality

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urinepotassium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urinesodium

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 urinevma

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 vitaminb12

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
  "acr",
  { data_type => "char", is_nullable => 1, size => 510 },
  "acth",
  { data_type => "char", is_nullable => 1, size => 510 },
  "albumin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "aldosterone",
  { data_type => "char", is_nullable => 1, size => 510 },
  "alp",
  { data_type => "char", is_nullable => 1, size => 510 },
  "alt",
  { data_type => "char", is_nullable => 1, size => 510 },
  "amylase",
  { data_type => "char", is_nullable => 1, size => 510 },
  "bicarb",
  { data_type => "char", is_nullable => 1, size => 510 },
  "bilirubin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "calcium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "chol_hdl_ratio",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cholesterol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ciclosporin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "corrected_calcium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cortisol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "creatinine",
  { data_type => "char", is_nullable => 1, size => 510 },
  "creatinineclearance",
  { data_type => "char", is_nullable => 1, size => 510 },
  "crp",
  { data_type => "char", is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", is_nullable => 1, size => 510 },
  "dheasulphate",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ferritin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "fsh",
  { data_type => "char", is_nullable => 1, size => 510 },
  "gfr",
  { data_type => "char", is_nullable => 1, size => 510 },
  "glucose",
  { data_type => "char", is_nullable => 1, size => 510 },
  "growthhormone",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hba1c",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hdl_cholesterol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "igf",
  { data_type => "char", is_nullable => 1, size => 510 },
  "lactate",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ldl_cholesterol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "lh",
  { data_type => "char", is_nullable => 1, size => 510 },
  "lipase",
  { data_type => "char", is_nullable => 1, size => 510 },
  "magnesium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "oestradiol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "osmolality",
  { data_type => "char", is_nullable => 1, size => 510 },
  "phosphate",
  { data_type => "char", is_nullable => 1, size => 510 },
  "potassium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "prolactin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "pth",
  { data_type => "char", is_nullable => 1, size => 510 },
  "pthpmol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "red_cell_folate",
  { data_type => "char", is_nullable => 1, size => 510 },
  "renin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", is_nullable => 1, size => 510 },
  "saturation",
  { data_type => "char", is_nullable => 1, size => 510 },
  "serum_iron",
  { data_type => "char", is_nullable => 1, size => 510 },
  "sirolimus",
  { data_type => "char", is_nullable => 1, size => 510 },
  "sodium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "t3",
  { data_type => "char", is_nullable => 1, size => 510 },
  "t4",
  { data_type => "char", is_nullable => 1, size => 510 },
  "tacrolimus",
  { data_type => "char", is_nullable => 1, size => 510 },
  "testosterone",
  { data_type => "char", is_nullable => 1, size => 510 },
  "total_ck",
  { data_type => "char", is_nullable => 1, size => 510 },
  "transferrin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "triglyceride",
  { data_type => "char", is_nullable => 1, size => 510 },
  "tsh",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urea",
  { data_type => "char", is_nullable => 1, size => 510 },
  "uric_acid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urine5hiaa",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urinefreecortisol",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urineosmolality",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urinepotassium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urinesodium",
  { data_type => "char", is_nullable => 1, size => 510 },
  "urinevma",
  { data_type => "char", is_nullable => 1, size => 510 },
  "vitaminb12",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t/ic7QeFjmpm90vXcLMt9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
