use utf8;
package CIMR::BloodDB::CtVirology;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CIMR::BloodDB::CtVirology

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<ct_virology>

=cut

__PACKAGE__->table("ct_virology");

=head1 ACCESSORS

=head2 table_id

  data_type: 'integer'
  is_nullable: 0
  size: 20

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

=head2 resname

  data_type: 'char'
  is_nullable: 1
  size: 100

=head2 resvalue

  data_type: 'char'
  is_nullable: 1
  size: 150

=cut

__PACKAGE__->add_columns(
  "table_id",
  { data_type => "integer", is_nullable => 0, size => 20 },
  "hospno",
  { data_type => "char", is_nullable => 1, size => 24 },
  "resdate",
  { data_type => "timestamp", is_nullable => 1 },
  "restime",
  { data_type => "timestamp", is_nullable => 1 },
  "resname",
  { data_type => "char", is_nullable => 1, size => 100 },
  "resvalue",
  { data_type => "char", is_nullable => 1, size => 150 },
);

=head1 PRIMARY KEY

=over 4

=item * L</table_id>

=back

=cut

__PACKAGE__->set_primary_key("table_id");


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-11-21 13:48:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QNE6cD0G/csHhu8sY9idOw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
