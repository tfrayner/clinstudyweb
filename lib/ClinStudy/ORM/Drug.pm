package ClinStudy::ORM::Drug;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::Drug

=cut

__PACKAGE__->table("drug");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 dose

  data_type: 'decimal'
  is_nullable: 1
  size: [12,5]

=head2 dose_unit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 dose_freq_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 dose_duration

  data_type: 'decimal'
  is_nullable: 1
  size: [12,5]

=head2 duration_unit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 dose_regime

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 locale_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 visit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 prior_treatment_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 hospitalisation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "dose",
  { data_type => "decimal", is_nullable => 1, size => [12, 5] },
  "dose_unit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "dose_freq_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "dose_duration",
  { data_type => "decimal", is_nullable => 1, size => [12, 5] },
  "duration_unit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "dose_regime",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "locale_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "visit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "prior_treatment_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "hospitalisation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name_id_4", ["name_id", "prior_treatment_id"]);
__PACKAGE__->add_unique_constraint("name_id_3", ["name_id", "hospitalisation_id"]);
__PACKAGE__->add_unique_constraint("name_id_2", ["name_id", "visit_id"]);

=head1 RELATIONS

=head2 dose_unit_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "dose_unit_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "dose_unit_id" },
);

=head2 dose_freq_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "dose_freq_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "dose_freq_id" },
);

=head2 name_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "name_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "name_id" },
);

=head2 locale_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "locale_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "locale_id" },
);

=head2 visit_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });

=head2 prior_treatment_id

Type: belongs_to

Related object: L<ClinStudy::ORM::PriorTreatment>

=cut

__PACKAGE__->belongs_to(
  "prior_treatment_id",
  "ClinStudy::ORM::PriorTreatment",
  { id => "prior_treatment_id" },
);

=head2 hospitalisation_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Hospitalisation>

=cut

__PACKAGE__->belongs_to(
  "hospitalisation_id",
  "ClinStudy::ORM::Hospitalisation",
  { id => "hospitalisation_id" },
);

=head2 duration_unit_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "duration_unit_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "duration_unit_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-15 17:08:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:THWXIIb7JIsXGh+n4adqnw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
