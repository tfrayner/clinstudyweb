use utf8;
package CIMR::BloodDB::ExpCtBloodbankConcat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CIMR::BloodDB::ExpCtBloodbankConcat

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<exp_ct_bloodbank_concat>

=cut

__PACKAGE__->table("exp_ct_bloodbank_concat");

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

=head2 antibodyspecificities1

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 antibodyspecificities2

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 bloodgroup

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 bloodtransfusions

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 deletedyn

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 diseasecodes

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 elisai

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 elisaii

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 ethnicorigin

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 events

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlaa1

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlaa2

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlab1

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlab2

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlabw

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlac1

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hlac2

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hladq1

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hladq2

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hladr1

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 hladr2

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 labcodeid

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 listdate

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 luminexi

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 luminexii

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentcll

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentclligg

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentclliggstrong

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentcllstrong

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentpbl

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentpbligg

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentpbliggstrong

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 percentpblstrong

  data_type: 'char'
  is_nullable: 1
  size: 510

=head2 pregnancies

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

=head2 uktnumber

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
  "antibodyspecificities1",
  { data_type => "char", is_nullable => 1, size => 510 },
  "antibodyspecificities2",
  { data_type => "char", is_nullable => 1, size => 510 },
  "bloodgroup",
  { data_type => "char", is_nullable => 1, size => 510 },
  "bloodtransfusions",
  { data_type => "char", is_nullable => 1, size => 510 },
  "deletedyn",
  { data_type => "char", is_nullable => 1, size => 510 },
  "diseasecodes",
  { data_type => "char", is_nullable => 1, size => 510 },
  "elisai",
  { data_type => "char", is_nullable => 1, size => 510 },
  "elisaii",
  { data_type => "char", is_nullable => 1, size => 510 },
  "ethnicorigin",
  { data_type => "char", is_nullable => 1, size => 510 },
  "events",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlaa1",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlaa2",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlab1",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlab2",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlabw",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlac1",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hlac2",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hladq1",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hladq2",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hladr1",
  { data_type => "char", is_nullable => 1, size => 510 },
  "hladr2",
  { data_type => "char", is_nullable => 1, size => 510 },
  "labcodeid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "listdate",
  { data_type => "char", is_nullable => 1, size => 510 },
  "luminexi",
  { data_type => "char", is_nullable => 1, size => 510 },
  "luminexii",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentcll",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentclligg",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentclliggstrong",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentcllstrong",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentpbl",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentpbligg",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentpbliggstrong",
  { data_type => "char", is_nullable => 1, size => 510 },
  "percentpblstrong",
  { data_type => "char", is_nullable => 1, size => 510 },
  "pregnancies",
  { data_type => "char", is_nullable => 1, size => 510 },
  "rowinsertdatetime",
  { data_type => "char", is_nullable => 1, size => 510 },
  "specimenid",
  { data_type => "char", is_nullable => 1, size => 510 },
  "uktnumber",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y8WqR3BBz38SX+gae4Ummg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
