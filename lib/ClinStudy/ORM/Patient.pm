use utf8;
package ClinStudy::ORM::Patient;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::Patient

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<patient>

=cut

__PACKAGE__->table("patient");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 year_of_birth

  data_type: 'year'
  is_nullable: 1

=head2 sex

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 trial_id

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 ethnicity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 home_centre_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 entry_date

  data_type: 'date'
  is_nullable: 0

=head2 notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "year_of_birth",
  { data_type => "year", is_nullable => 1 },
  "sex",
  { data_type => "char", is_nullable => 1, size => 1 },
  "trial_id",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "ethnicity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "home_centre_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "entry_date",
  { data_type => "date", is_nullable => 0 },
  "notes",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<trial_id>

=over 4

=item * L</trial_id>

=back

=cut

__PACKAGE__->add_unique_constraint("trial_id", ["trial_id"]);

=head1 RELATIONS

=head2 adverse_events

Type: has_many

Related object: L<ClinStudy::ORM::AdverseEvent>

=cut

__PACKAGE__->has_many(
  "adverse_events",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 clinical_features

Type: has_many

Related object: L<ClinStudy::ORM::ClinicalFeature>

=cut

__PACKAGE__->has_many(
  "clinical_features",
  "ClinStudy::ORM::ClinicalFeature",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 comorbidities

Type: has_many

Related object: L<ClinStudy::ORM::Comorbidity>

=cut

__PACKAGE__->has_many(
  "comorbidities",
  "ClinStudy::ORM::Comorbidity",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 diagnoses

Type: has_many

Related object: L<ClinStudy::ORM::Diagnosis>

=cut

__PACKAGE__->has_many(
  "diagnoses",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 disease_events

Type: has_many

Related object: L<ClinStudy::ORM::DiseaseEvent>

=cut

__PACKAGE__->has_many(
  "disease_events",
  "ClinStudy::ORM::DiseaseEvent",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 ethnicity_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "ethnicity_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "ethnicity_id" },
);

=head2 home_centre_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "home_centre_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "home_centre_id" },
);

=head2 hospitalisations

Type: has_many

Related object: L<ClinStudy::ORM::Hospitalisation>

=cut

__PACKAGE__->has_many(
  "hospitalisations",
  "ClinStudy::ORM::Hospitalisation",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 patient_prior_groups

Type: has_many

Related object: L<ClinStudy::ORM::PatientPriorGroup>

=cut

__PACKAGE__->has_many(
  "patient_prior_groups",
  "ClinStudy::ORM::PatientPriorGroup",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 prior_observations

Type: has_many

Related object: L<ClinStudy::ORM::PriorObservation>

=cut

__PACKAGE__->has_many(
  "prior_observations",
  "ClinStudy::ORM::PriorObservation",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 prior_treatments

Type: has_many

Related object: L<ClinStudy::ORM::PriorTreatment>

=cut

__PACKAGE__->has_many(
  "prior_treatments",
  "ClinStudy::ORM::PriorTreatment",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 risk_factors

Type: has_many

Related object: L<ClinStudy::ORM::RiskFactor>

=cut

__PACKAGE__->has_many(
  "risk_factors",
  "ClinStudy::ORM::RiskFactor",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 studies

Type: has_many

Related object: L<ClinStudy::ORM::Study>

=cut

__PACKAGE__->has_many(
  "studies",
  "ClinStudy::ORM::Study",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 system_involvements

Type: has_many

Related object: L<ClinStudy::ORM::SystemInvolvement>

=cut

__PACKAGE__->has_many(
  "system_involvements",
  "ClinStudy::ORM::SystemInvolvement",
  { "foreign.patient_id" => "self.id" },
  {},
);

=head2 visits

Type: has_many

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->has_many(
  "visits",
  "ClinStudy::ORM::Visit",
  { "foreign.patient_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sldVR9SlIY3IJVdSMTUBMQ


# You can replace this text with custom content, and it will be preserved on regeneration

# Custom has_many so that we track the cascade_delete behaviour of the
# database correctly (D::C::Schema::Loader doesn't do this yet). These
# relationships replace the autogenerated ones above, and the latter
# can be deleted when we're finally done with D::C::S::L). FIXME

__PACKAGE__->has_many(
  "adverse_events",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "visits",
  "ClinStudy::ORM::Visit",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "hospitalisations",
  "ClinStudy::ORM::Hospitalisation",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "diagnoses",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "disease_events",
  "ClinStudy::ORM::DiseaseEvent",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "comorbidities",
  "ClinStudy::ORM::Comorbidity",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "prior_observations",
  "ClinStudy::ORM::PriorObservation",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "prior_treatments",
  "ClinStudy::ORM::PriorTreatment",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "risk_factors",
  "ClinStudy::ORM::RiskFactor",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "studies",
  "ClinStudy::ORM::Study",
  { "foreign.patient_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:

# (NOTE that this is a one-way relationship, will need to add similar
# to ControlledVocab.pm if we ever want to navigate in the reverse
# direction).
__PACKAGE__->many_to_many(
    "system_involvement_types" => "system_involvements", "type_id"
);
__PACKAGE__->many_to_many(
    "clinical_feature_types" => "clinical_features", "type_id"
);
__PACKAGE__->many_to_many(
    "risk_factor_types" => "risk_factors", "type_id"
);
__PACKAGE__->many_to_many(
    "prior_groups" => "patient_prior_groups", "prior_group_id"
);

1;
