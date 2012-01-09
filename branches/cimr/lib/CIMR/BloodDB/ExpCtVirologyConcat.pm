use utf8;
package CIMR::BloodDB::ExpCtVirologyConcat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CIMR::BloodDB::ExpCtVirologyConcat

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<exp_ct_virology_concat>

=cut

__PACKAGE__->table("exp_ct_virology_concat");

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

=head2 anti_hbs_post_vaccination

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cmv_igg

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cmv_latex

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 cmv_pcr

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 deletedyn

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ebv_vca_igg

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hepbsag

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hepc

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hiv

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hsv

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 labcodeid

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

=head2 toxo

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 vzv

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
  "anti_hbs_post_vaccination",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cmv_igg",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cmv_latex",
  { data_type => "char", is_nullable => 1, size => 510 },
  "cmv_pcr",
  { data_type => "char", is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ebv_vca_igg",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hepbsag",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hepc",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hiv",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hsv",
  { data_type => "char", is_nullable => 1, size => 510 },
  "labcodeid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "toxo",
  { data_type => "char", is_nullable => 1, size => 510 },
  "vzv",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2i9l3bkonyTIvlZMyfOFhA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
