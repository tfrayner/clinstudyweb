use utf8;
package ClinStudy::ORM::AdverseEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::AdverseEvent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<adverse_event>

=cut

__PACKAGE__->table("adverse_event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 start_date

  data_type: 'date'
  is_nullable: 0

=head2 end_date

  data_type: 'date'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 severity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 action_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 outcome_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 trial_related_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "start_date",
  { data_type => "date", is_nullable => 0 },
  "end_date",
  { data_type => "date", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "severity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "action_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "outcome_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "trial_related_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 action_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "action_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "action_id" },
);

=head2 outcome_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "outcome_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "outcome_id" },
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

=head2 severity_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "severity_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "severity_id" },
);

=head2 trial_related_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "trial_related_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "trial_related_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jBHS6hYMjzoN/MAndiy15w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
