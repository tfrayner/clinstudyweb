use utf8;
package ClinStudy::ORM::Visit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::Visit

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<visit>

=cut

__PACKAGE__->table("visit");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 date

  data_type: 'date'
  is_nullable: 0

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 disease_activity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 nominal_timepoint_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 treatment_escalation

  data_type: 'tinyint'
  is_nullable: 1

=head2 has_infection

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "date",
  { data_type => "date", is_nullable => 0 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "disease_activity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "nominal_timepoint_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "treatment_escalation",
  { data_type => "tinyint", is_nullable => 1 },
  "has_infection",
  { data_type => "tinyint", is_nullable => 1 },
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

=item * L</date>

=back

=cut

__PACKAGE__->add_unique_constraint("patient_id", ["patient_id", "date"]);

=head1 RELATIONS

=head2 disease_activity_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "disease_activity_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "disease_activity_id" },
);

=head2 drugs

Type: has_many

Related object: L<ClinStudy::ORM::Drug>

=cut

__PACKAGE__->has_many(
  "drugs",
  "ClinStudy::ORM::Drug",
  { "foreign.visit_id" => "self.id" },
  {},
);

=head2 nominal_timepoint_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "nominal_timepoint_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "nominal_timepoint_id" },
);

=head2 patient_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Patient>

=cut

__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);

=head2 phenotype_quantities

Type: has_many

Related object: L<ClinStudy::ORM::PhenotypeQuantity>

=cut

__PACKAGE__->has_many(
  "phenotype_quantities",
  "ClinStudy::ORM::PhenotypeQuantity",
  { "foreign.visit_id" => "self.id" },
  {},
);

=head2 samples

Type: has_many

Related object: L<ClinStudy::ORM::Sample>

=cut

__PACKAGE__->has_many(
  "samples",
  "ClinStudy::ORM::Sample",
  { "foreign.visit_id" => "self.id" },
  {},
);

=head2 test_results

Type: has_many

Related object: L<ClinStudy::ORM::TestResult>

=cut

__PACKAGE__->has_many(
  "test_results",
  "ClinStudy::ORM::TestResult",
  { "foreign.visit_id" => "self.id" },
  {},
);

=head2 visit_data_files

Type: has_many

Related object: L<ClinStudy::ORM::VisitDataFile>

=cut

__PACKAGE__->has_many(
  "visit_data_files",
  "ClinStudy::ORM::VisitDataFile",
  { "foreign.visit_id" => "self.id" },
  {},
);

=head2 visit_emergent_groups

Type: has_many

Related object: L<ClinStudy::ORM::VisitEmergentGroup>

=cut

__PACKAGE__->has_many(
  "visit_emergent_groups",
  "ClinStudy::ORM::VisitEmergentGroup",
  { "foreign.visit_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5OpCreiTOfL6K9ji1rHv3w


# You can replace this text with custom content, and it will be preserved on regeneration

# Custom has_many so that we track the cascade_delete behaviour of the
# database correctly (D::C::Schema::Loader doesn't do this yet). These
# relationships replace the autogenerated ones above, and the latter
# can be deleted when we're finally done with D::C::S::L). FIXME
__PACKAGE__->has_many(
  "drugs",
  "ClinStudy::ORM::Drug",
  { "foreign.visit_id" => "self.id" },
  { "cascade_delete"   => 0 },
);
__PACKAGE__->has_many(
  "samples",
  "ClinStudy::ORM::Sample",
  { "foreign.visit_id" => "self.id" },
  { "cascade_delete"   => 0 },
);
__PACKAGE__->has_many(
  "test_results",
  "ClinStudy::ORM::TestResult",
  { "foreign.visit_id" => "self.id" },
  { "cascade_delete"   => 0 },
);
__PACKAGE__->has_many(
  "visit_data_files",
  "ClinStudy::ORM::VisitDataFile",
  { "foreign.visit_id" => "self.id" },
  { "cascade_delete"   => 0 },
);


# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:
__PACKAGE__->many_to_many(
    "emergent_groups" => "visit_emergent_groups", "emergent_group_id"
);

1;
