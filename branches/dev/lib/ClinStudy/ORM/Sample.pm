package ClinStudy::ORM::Sample;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::Sample

=cut

__PACKAGE__->table("sample");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 31

=head2 visit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 cell_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 material_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 num_aliquots

  data_type: 'integer'
  is_nullable: 1

=head2 freezer_location

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 freezer_box

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 box_slot

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 concentration

  data_type: 'decimal'
  is_nullable: 1
  size: [12,5]

=head2 purity

  data_type: 'decimal'
  is_nullable: 1
  size: [12,5]

=head2 cell_purity

  data_type: 'decimal'
  is_nullable: 1
  size: [12,5]

=head2 quality_score_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 has_expired

  data_type: 'tinyint'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 31 },
  "visit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "cell_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "material_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "num_aliquots",
  { data_type => "integer", is_nullable => 1 },
  "freezer_location",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "freezer_box",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "box_slot",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "concentration",
  { data_type => "decimal", is_nullable => 1, size => [12, 5] },
  "purity",
  { data_type => "decimal", is_nullable => 1, size => [12, 5] },
  "cell_purity",
  { data_type => "decimal", is_nullable => 1, size => [12, 5] },
  "quality_score_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "has_expired",
  { data_type => "tinyint", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 channels

Type: has_many

Related object: L<ClinStudy::ORM::Channel>

=cut

__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.sample_id" => "self.id" },
  {},
);

=head2 visit_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });

=head2 cell_type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "cell_type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "cell_type_id" },
);

=head2 material_type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "material_type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "material_type_id" },
);

=head2 quality_score_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "quality_score_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "quality_score_id" },
);

=head2 sample_data_files

Type: has_many

Related object: L<ClinStudy::ORM::SampleDataFile>

=cut

__PACKAGE__->has_many(
  "sample_data_files",
  "ClinStudy::ORM::SampleDataFile",
  { "foreign.sample_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2011-10-11 11:27:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kS06drAzlFQj2fjU2eud6Q


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.sample_id" => "self.id" },
  { "cascade_delete"     => 0 },
);
__PACKAGE__->has_many(
  "sample_data_files",
  "ClinStudy::ORM::SampleDataFile",
  { "foreign.sample_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

__PACKAGE__->many_to_many(
    "assays" => "channels", "assay_id"
);

1;
