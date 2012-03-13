use utf8;
package ClinStudy::ORM::Comorbidity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::Comorbidity

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<comorbidity>

=cut

__PACKAGE__->table("comorbidity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 condition_name

  data_type: 'varchar'
  is_nullable: 0
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
  "condition_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
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

=item * L</condition_name>

=item * L</date>

=back

=cut

__PACKAGE__->add_unique_constraint("patient_id", ["patient_id", "condition_name", "date"]);

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


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2iz7ConW1kiTtLogxbLKrA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
