use utf8;
package ClinStudy::ORM::PriorObservation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::PriorObservation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<prior_observation>

=cut

__PACKAGE__->table("prior_observation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date",
  { data_type => "date", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<patient_id>

=over 4

=item * L</patient_id>

=item * L</type_id>

=item * L</date>

=back

=cut

__PACKAGE__->add_unique_constraint("patient_id", ["patient_id", "type_id", "date"]);

=head1 RELATIONS

=head2 patient_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Patient>

=cut

__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);

=head2 type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-03-20 18:17:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nrzizW6W3uixwDGYnjHkGQ


use overload '""' => sub { join(':', $_[0]->patient_id, $_[0]->type_id) }, fallback => 1;

1;
