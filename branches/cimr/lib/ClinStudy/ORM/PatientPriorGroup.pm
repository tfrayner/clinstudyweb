use utf8;
package ClinStudy::ORM::PatientPriorGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::PatientPriorGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<patient_prior_group>

=cut

__PACKAGE__->table("patient_prior_group");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 prior_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "prior_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=item * L</prior_group_id>

=back

=cut

__PACKAGE__->add_unique_constraint("patient_id", ["patient_id", "prior_group_id"]);

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

=head2 prior_group_id

Type: belongs_to

Related object: L<ClinStudy::ORM::PriorGroup>

=cut

__PACKAGE__->belongs_to(
  "prior_group_id",
  "ClinStudy::ORM::PriorGroup",
  { id => "prior_group_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rpqD2h+9SKD4ClXw5/J+uQ

use overload '""' => sub { join(':', $_[0]->patient_id, $_[0]->prior_group_id) }, fallback => 1;

1;
