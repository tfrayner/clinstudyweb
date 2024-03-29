use utf8;
package ClinStudy::ORM::Transplant;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::Transplant

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<transplant>

=cut

__PACKAGE__->table("transplant");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'date'
  is_nullable: 1

=head2 number

  data_type: 'integer'
  is_nullable: 1

=head2 sensitisation_status_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 recip_cmv

  data_type: 'tinyint'
  is_nullable: 1

=head2 delayed_graft_function_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 days_delayed_function

  data_type: 'integer'
  is_nullable: 1

=head2 organ_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 mins_cold_ischaemic

  data_type: 'integer'
  is_nullable: 1

=head2 reperfusion_quality_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 hla_mismatch

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 donor_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 donor_age

  data_type: 'integer'
  is_nullable: 1

=head2 donor_cause_of_death

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 donor_cmv

  data_type: 'tinyint'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date",
  { data_type => "date", is_nullable => 1 },
  "number",
  { data_type => "integer", is_nullable => 1 },
  "sensitisation_status_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "recip_cmv",
  { data_type => "tinyint", is_nullable => 1 },
  "delayed_graft_function_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "days_delayed_function",
  { data_type => "integer", is_nullable => 1 },
  "organ_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "mins_cold_ischaemic",
  { data_type => "integer", is_nullable => 1 },
  "reperfusion_quality_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "hla_mismatch",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "donor_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "donor_age",
  { data_type => "integer", is_nullable => 1 },
  "donor_cause_of_death",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "donor_cmv",
  { data_type => "tinyint", is_nullable => 1 },
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

=head2 C<patient_id>

=over 4

=item * L</patient_id>

=item * L</date>

=back

=cut

__PACKAGE__->add_unique_constraint("patient_id", ["patient_id", "date"]);

=head1 RELATIONS

=head2 delayed_graft_function_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "delayed_graft_function_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "delayed_graft_function_id" },
);

=head2 donor_type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "donor_type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "donor_type_id" },
);

=head2 graft_failures

Type: has_many

Related object: L<ClinStudy::ORM::GraftFailure>

=cut

__PACKAGE__->has_many(
  "graft_failures",
  "ClinStudy::ORM::GraftFailure",
  { "foreign.transplant_id" => "self.id" },
  {},
);

=head2 organ_type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "organ_type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "organ_type_id" },
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

=head2 reperfusion_quality_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "reperfusion_quality_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "reperfusion_quality_id" },
);

=head2 sensitisation_status_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "sensitisation_status_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "sensitisation_status_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-02-29 16:21:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZFLPsvldYNYxNI73YIaJXg


# You can replace this text with custom content, and it will be preserved on regeneration

# Custom has_many so that we track the cascade_delete behaviour of the
# database correctly (D::C::Schema::Loader doesn't do this yet). These
# relationships replace the autogenerated ones above, and the latter
# can be deleted when we're finally done with D::C::S::L). FIXME

__PACKAGE__->has_many(
  "graft_failures",
  "ClinStudy::ORM::GraftFailure",
  { "foreign.transplant_id" => "self.id" },
  { "cascade_delete"        => 0 },
);

use overload '""' => sub { join(':', $_[0]->patient_id,
                                $_[0]->organ_type_id, $_[0]->date || q{}) }, fallback => 1;

1;
