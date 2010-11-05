package ClinStudy::ORM::Diagnosis;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::Diagnosis

=cut

__PACKAGE__->table("diagnosis");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 condition_name_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 confidence_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 date

  data_type: 'date'
  is_nullable: 1

=head2 previous_episodes

  data_type: 'tinyint'
  is_nullable: 1

=head2 previous_course_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 previous_duration_months

  data_type: 'decimal'
  is_nullable: 1
  size: [12,5]

=head2 disease_staging_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 disease_extent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "condition_name_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "confidence_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "date",
  { data_type => "date", is_nullable => 1 },
  "previous_episodes",
  { data_type => "tinyint", is_nullable => 1 },
  "previous_course_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "previous_duration_months",
  { data_type => "decimal", is_nullable => 1, size => [12, 5] },
  "disease_staging_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "disease_extent_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("patient_id", ["patient_id", "date"]);

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

=head2 condition_name_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "condition_name_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "condition_name_id" },
);

=head2 confidence_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "confidence_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "confidence_id" },
);

=head2 previous_course_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "previous_course_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "previous_course_id" },
);

=head2 disease_staging_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "disease_staging_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "disease_staging_id" },
);

=head2 disease_extent_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "disease_extent_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "disease_extent_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-11-04 17:45:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:emUCx6FjYDM5qMWBwlMqgw


# You can replace this text with custom content, and it will be preserved on regeneration

1;
