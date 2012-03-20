use utf8;
package ClinStudy::ORM::EmergentGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::EmergentGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<emergent_group>

=cut

__PACKAGE__->table("emergent_group");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 basis_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "basis_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=item * L</type_id>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name", "type_id"]);

=head1 RELATIONS

=head2 basis_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "basis_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "basis_id" },
);

=head2 type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);

=head2 visit_emergent_groups

Type: has_many

Related object: L<ClinStudy::ORM::VisitEmergentGroup>

=cut

__PACKAGE__->has_many(
  "visit_emergent_groups",
  "ClinStudy::ORM::VisitEmergentGroup",
  { "foreign.emergent_group_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VAkr702h5Kss/BUN2UM53A


# You can replace this text with custom content, and it will be preserved on regeneration

# This cascading delete is only allowed from the visit, not the
# group.
__PACKAGE__->has_many(
  "visit_emergent_groups",
  "ClinStudy::ORM::VisitEmergentGroup",
  { "foreign.emergent_group_id" => "self.id" },
  { "cascade_delete"   => 0 },
);

# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:
__PACKAGE__->many_to_many(
    "visits" => "visit_emergent_groups", "visit_id",
  { "cascade_delete"   => 0 },
);

# Default stringification method.
use overload '""' => sub { $_[0]->type_id()->value . ':' . $_[0]->name }, fallback => 1;

1;
