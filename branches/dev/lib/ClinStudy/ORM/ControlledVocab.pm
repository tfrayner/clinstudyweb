package ClinStudy::ORM::ControlledVocab;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::ControlledVocab

=cut

__PACKAGE__->table("controlled_vocab");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 accession

  data_type: 'varchar'
  is_nullable: 0
  size: 31

=head2 category

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 term_source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "accession",
  { data_type => "varchar", is_nullable => 0, size => 31 },
  "category",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "term_source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("category", ["category", "value"]);
__PACKAGE__->add_unique_constraint("accession", ["accession"]);

=head1 RELATIONS

=head2 adverse_event_severity_ids

Type: has_many

Related object: L<ClinStudy::ORM::AdverseEvent>

=cut

__PACKAGE__->has_many(
  "adverse_event_severity_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.severity_id" => "self.id" },
  {},
);

=head2 adverse_event_action_ids

Type: has_many

Related object: L<ClinStudy::ORM::AdverseEvent>

=cut

__PACKAGE__->has_many(
  "adverse_event_action_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.action_id" => "self.id" },
  {},
);

=head2 adverse_event_outcome_ids

Type: has_many

Related object: L<ClinStudy::ORM::AdverseEvent>

=cut

__PACKAGE__->has_many(
  "adverse_event_outcome_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.outcome_id" => "self.id" },
  {},
);

=head2 adverse_event_trial_related_ids

Type: has_many

Related object: L<ClinStudy::ORM::AdverseEvent>

=cut

__PACKAGE__->has_many(
  "adverse_event_trial_related_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.trial_related_id" => "self.id" },
  {},
);

=head2 assay_batches

Type: has_many

Related object: L<ClinStudy::ORM::AssayBatch>

=cut

__PACKAGE__->has_many(
  "assay_batches",
  "ClinStudy::ORM::AssayBatch",
  { "foreign.platform_id" => "self.id" },
  {},
);

=head2 channels

Type: has_many

Related object: L<ClinStudy::ORM::Channel>

=cut

__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.label_id" => "self.id" },
  {},
);

=head2 clinical_features

Type: has_many

Related object: L<ClinStudy::ORM::ClinicalFeature>

=cut

__PACKAGE__->has_many(
  "clinical_features",
  "ClinStudy::ORM::ClinicalFeature",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 term_source_id

Type: belongs_to

Related object: L<ClinStudy::ORM::TermSource>

=cut

__PACKAGE__->belongs_to(
  "term_source_id",
  "ClinStudy::ORM::TermSource",
  { id => "term_source_id" },
);

=head2 diagnosis_condition_name_ids

Type: has_many

Related object: L<ClinStudy::ORM::Diagnosis>

=cut

__PACKAGE__->has_many(
  "diagnosis_condition_name_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.condition_name_id" => "self.id" },
  {},
);

=head2 diagnosis_confidence_ids

Type: has_many

Related object: L<ClinStudy::ORM::Diagnosis>

=cut

__PACKAGE__->has_many(
  "diagnosis_confidence_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.confidence_id" => "self.id" },
  {},
);

=head2 diagnosis_previous_course_ids

Type: has_many

Related object: L<ClinStudy::ORM::Diagnosis>

=cut

__PACKAGE__->has_many(
  "diagnosis_previous_course_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.previous_course_id" => "self.id" },
  {},
);

=head2 diagnosis_disease_staging_ids

Type: has_many

Related object: L<ClinStudy::ORM::Diagnosis>

=cut

__PACKAGE__->has_many(
  "diagnosis_disease_staging_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.disease_staging_id" => "self.id" },
  {},
);

=head2 diagnosis_disease_extent_ids

Type: has_many

Related object: L<ClinStudy::ORM::Diagnosis>

=cut

__PACKAGE__->has_many(
  "diagnosis_disease_extent_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.disease_extent_id" => "self.id" },
  {},
);

=head2 disease_events

Type: has_many

Related object: L<ClinStudy::ORM::DiseaseEvent>

=cut

__PACKAGE__->has_many(
  "disease_events",
  "ClinStudy::ORM::DiseaseEvent",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 drug_dose_unit_ids

Type: has_many

Related object: L<ClinStudy::ORM::Drug>

=cut

__PACKAGE__->has_many(
  "drug_dose_unit_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.dose_unit_id" => "self.id" },
  {},
);

=head2 drug_dose_freq_ids

Type: has_many

Related object: L<ClinStudy::ORM::Drug>

=cut

__PACKAGE__->has_many(
  "drug_dose_freq_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.dose_freq_id" => "self.id" },
  {},
);

=head2 drug_name_ids

Type: has_many

Related object: L<ClinStudy::ORM::Drug>

=cut

__PACKAGE__->has_many(
  "drug_name_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.name_id" => "self.id" },
  {},
);

=head2 drug_locale_ids

Type: has_many

Related object: L<ClinStudy::ORM::Drug>

=cut

__PACKAGE__->has_many(
  "drug_locale_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.locale_id" => "self.id" },
  {},
);

=head2 drug_duration_unit_ids

Type: has_many

Related object: L<ClinStudy::ORM::Drug>

=cut

__PACKAGE__->has_many(
  "drug_duration_unit_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.duration_unit_id" => "self.id" },
  {},
);

=head2 emergent_group_basis_ids

Type: has_many

Related object: L<ClinStudy::ORM::EmergentGroup>

=cut

__PACKAGE__->has_many(
  "emergent_group_basis_ids",
  "ClinStudy::ORM::EmergentGroup",
  { "foreign.basis_id" => "self.id" },
  {},
);

=head2 emergent_group_type_ids

Type: has_many

Related object: L<ClinStudy::ORM::EmergentGroup>

=cut

__PACKAGE__->has_many(
  "emergent_group_type_ids",
  "ClinStudy::ORM::EmergentGroup",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 patient_ethnicity_ids

Type: has_many

Related object: L<ClinStudy::ORM::Patient>

=cut

__PACKAGE__->has_many(
  "patient_ethnicity_ids",
  "ClinStudy::ORM::Patient",
  { "foreign.ethnicity_id" => "self.id" },
  {},
);

=head2 patient_home_centre_ids

Type: has_many

Related object: L<ClinStudy::ORM::Patient>

=cut

__PACKAGE__->has_many(
  "patient_home_centre_ids",
  "ClinStudy::ORM::Patient",
  { "foreign.home_centre_id" => "self.id" },
  {},
);

=head2 prior_groups

Type: has_many

Related object: L<ClinStudy::ORM::PriorGroup>

=cut

__PACKAGE__->has_many(
  "prior_groups",
  "ClinStudy::ORM::PriorGroup",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 prior_observations

Type: has_many

Related object: L<ClinStudy::ORM::PriorObservation>

=cut

__PACKAGE__->has_many(
  "prior_observations",
  "ClinStudy::ORM::PriorObservation",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 prior_treatments

Type: has_many

Related object: L<ClinStudy::ORM::PriorTreatment>

=cut

__PACKAGE__->has_many(
  "prior_treatments",
  "ClinStudy::ORM::PriorTreatment",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 related_vocab_controlled_vocab_ids

Type: has_many

Related object: L<ClinStudy::ORM::RelatedVocab>

=cut

__PACKAGE__->has_many(
  "related_vocab_controlled_vocab_ids",
  "ClinStudy::ORM::RelatedVocab",
  { "foreign.controlled_vocab_id" => "self.id" },
  {},
);

=head2 related_vocab_target_ids

Type: has_many

Related object: L<ClinStudy::ORM::RelatedVocab>

=cut

__PACKAGE__->has_many(
  "related_vocab_target_ids",
  "ClinStudy::ORM::RelatedVocab",
  { "foreign.target_id" => "self.id" },
  {},
);

=head2 related_vocab_relationship_ids

Type: has_many

Related object: L<ClinStudy::ORM::RelatedVocab>

=cut

__PACKAGE__->has_many(
  "related_vocab_relationship_ids",
  "ClinStudy::ORM::RelatedVocab",
  { "foreign.relationship_id" => "self.id" },
  {},
);

=head2 risk_factors

Type: has_many

Related object: L<ClinStudy::ORM::RiskFactor>

=cut

__PACKAGE__->has_many(
  "risk_factors",
  "ClinStudy::ORM::RiskFactor",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 sample_cell_type_ids

Type: has_many

Related object: L<ClinStudy::ORM::Sample>

=cut

__PACKAGE__->has_many(
  "sample_cell_type_ids",
  "ClinStudy::ORM::Sample",
  { "foreign.cell_type_id" => "self.id" },
  {},
);

=head2 sample_material_type_ids

Type: has_many

Related object: L<ClinStudy::ORM::Sample>

=cut

__PACKAGE__->has_many(
  "sample_material_type_ids",
  "ClinStudy::ORM::Sample",
  { "foreign.material_type_id" => "self.id" },
  {},
);

=head2 sample_quality_score_ids

Type: has_many

Related object: L<ClinStudy::ORM::Sample>

=cut

__PACKAGE__->has_many(
  "sample_quality_score_ids",
  "ClinStudy::ORM::Sample",
  { "foreign.quality_score_id" => "self.id" },
  {},
);

=head2 sample_data_files

Type: has_many

Related object: L<ClinStudy::ORM::SampleDataFile>

=cut

__PACKAGE__->has_many(
  "sample_data_files",
  "ClinStudy::ORM::SampleDataFile",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 studies

Type: has_many

Related object: L<ClinStudy::ORM::Study>

=cut

__PACKAGE__->has_many(
  "studies",
  "ClinStudy::ORM::Study",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 system_involvements

Type: has_many

Related object: L<ClinStudy::ORM::SystemInvolvement>

=cut

__PACKAGE__->has_many(
  "system_involvements",
  "ClinStudy::ORM::SystemInvolvement",
  { "foreign.type_id" => "self.id" },
  {},
);

=head2 test_possible_values

Type: has_many

Related object: L<ClinStudy::ORM::TestPossibleValue>

=cut

__PACKAGE__->has_many(
  "test_possible_values",
  "ClinStudy::ORM::TestPossibleValue",
  { "foreign.possible_value_id" => "self.id" },
  {},
);

=head2 test_results

Type: has_many

Related object: L<ClinStudy::ORM::TestResult>

=cut

__PACKAGE__->has_many(
  "test_results",
  "ClinStudy::ORM::TestResult",
  { "foreign.controlled_value_id" => "self.id" },
  {},
);

=head2 transplant_sensitisation_status_ids

Type: has_many

Related object: L<ClinStudy::ORM::Transplant>

=cut

__PACKAGE__->has_many(
  "transplant_sensitisation_status_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.sensitisation_status_id" => "self.id" },
  {},
);

=head2 transplant_organ_type_ids

Type: has_many

Related object: L<ClinStudy::ORM::Transplant>

=cut

__PACKAGE__->has_many(
  "transplant_organ_type_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.organ_type_id" => "self.id" },
  {},
);

=head2 transplant_reperfusion_quality_ids

Type: has_many

Related object: L<ClinStudy::ORM::Transplant>

=cut

__PACKAGE__->has_many(
  "transplant_reperfusion_quality_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.reperfusion_quality_id" => "self.id" },
  {},
);

=head2 transplant_donor_type_ids

Type: has_many

Related object: L<ClinStudy::ORM::Transplant>

=cut

__PACKAGE__->has_many(
  "transplant_donor_type_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.donor_type_id" => "self.id" },
  {},
);

=head2 visit_disease_activity_ids

Type: has_many

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->has_many(
  "visit_disease_activity_ids",
  "ClinStudy::ORM::Visit",
  { "foreign.disease_activity_id" => "self.id" },
  {},
);

=head2 visit_nominal_timepoint_ids

Type: has_many

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->has_many(
  "visit_nominal_timepoint_ids",
  "ClinStudy::ORM::Visit",
  { "foreign.nominal_timepoint_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2011-10-11 11:27:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mTFQH4agh9W5cyTKcVt2cg


# You can replace this text with custom content, and it will be preserved on regeneration

# FIXME add { cascade_delete => 0 } to all the has_many relationships
# above once autogeneration is no longer used.

__PACKAGE__->has_many(
  "adverse_event_severity_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.severity_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "adverse_event_action_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.action_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "adverse_event_outcome_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.outcome_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "adverse_event_trial_related_ids",
  "ClinStudy::ORM::AdverseEvent",
  { "foreign.trial_related_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.label_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "diagnosis_condition_name_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.condition_name_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "diagnosis_confidence_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.confidence_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "diagnosis_previous_course_ids",
  "ClinStudy::ORM::Diagnosis",
  { "foreign.previous_course_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "disease_events",
  "ClinStudy::ORM::DiseaseEvent",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "drug_name_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.name_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "drug_dose_unit_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.dose_unit_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "drug_dose_freq_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.dose_freq_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "drug_locale_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.locale_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "emergent_group_basis_ids",
  "ClinStudy::ORM::EmergentGroup",
  { "foreign.basis_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "emergent_group_type_ids",
  "ClinStudy::ORM::EmergentGroup",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "patient_ethnicity_ids",
  "ClinStudy::ORM::Patient",
  { "foreign.ethnicity_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "patient_home_centre_ids",
  "ClinStudy::ORM::Patient",
  { "foreign.home_centre_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "system_involvements",
  "ClinStudy::ORM::SystemInvolvement",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "sample_data_files",
  "ClinStudy::ORM::SampleDataFile",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"  => 0 },
);
__PACKAGE__->has_many(
  "studies",
  "ClinStudy::ORM::Study",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"  => 0 },
);
__PACKAGE__->has_many(
  "prior_groups",
  "ClinStudy::ORM::PriorGroup",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"  => 0 },
);
__PACKAGE__->has_many(
  "prior_observations",
  "ClinStudy::ORM::PriorObservation",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "prior_treatments",
  "ClinStudy::ORM::PriorTreatment",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "sample_cell_type_ids",
  "ClinStudy::ORM::Sample",
  { "foreign.cell_type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "sample_material_type_ids",
  "ClinStudy::ORM::Sample",
  { "foreign.material_type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "test_possible_values",
  "ClinStudy::ORM::TestPossibleValue",
  { "foreign.possible_value_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "test_results",
  "ClinStudy::ORM::TestResult",
  { "foreign.controlled_value_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "transplant_sensitisation_status_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.sensitisation_status_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "transplant_organ_type_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.organ_type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "transplant_reperfusion_quality_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.reperfusion_quality_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "transplant_donor_type_ids",
  "ClinStudy::ORM::Transplant",
  { "foreign.donor_type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "visits",
  "ClinStudy::ORM::Visit",
  { "foreign.disease_activity_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "visit_nominal_timepoint_ids",
  "ClinStudy::ORM::Visit",
  { "foreign.nominal_timepoint_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "clinical_features",
  "ClinStudy::ORM::ClinicalFeature",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "drug_duration_unit_ids",
  "ClinStudy::ORM::Drug",
  { "foreign.duration_unit_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "risk_factors",
  "ClinStudy::ORM::RiskFactor",
  { "foreign.type_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "sample_quality_score_ids",
  "ClinStudy::ORM::Sample",
  { "foreign.quality_score_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "assay_batches",
  "ClinStudy::ORM::AssayBatch",
  { "foreign.platform_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "related_vocab_controlled_vocab_ids",
  "ClinStudy::ORM::RelatedVocab",
  { "foreign.controlled_vocab_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "related_vocab_target_ids",
  "ClinStudy::ORM::RelatedVocab",
  { "foreign.target_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "related_vocab_relationship_ids",
  "ClinStudy::ORM::RelatedVocab",
  { "foreign.relationship_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:
__PACKAGE__->many_to_many(
    "related_controlled_vocabs" => "related_vocab_controlled_vocab_ids", "controlled_vocab_id",
  { "cascade_delete"   => 0 },
);
__PACKAGE__->many_to_many(
    "related_targets" => "related_vocab_target_ids", "target_id",
  { "cascade_delete"   => 0 },
);
__PACKAGE__->many_to_many(
    "relationships"   => "related_vocab_relationship_ids", "relationship_id",
  { "cascade_delete"   => 0 },
);

1;
