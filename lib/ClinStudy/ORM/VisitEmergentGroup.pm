use utf8;
package ClinStudy::ORM::VisitEmergentGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::VisitEmergentGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<visit_emergent_group>

=cut

__PACKAGE__->table("visit_emergent_group");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 visit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 emergent_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "visit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "emergent_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<visit_id>

=over 4

=item * L</visit_id>

=item * L</emergent_group_id>

=back

=cut

__PACKAGE__->add_unique_constraint("visit_id", ["visit_id", "emergent_group_id"]);

=head1 RELATIONS

=head2 emergent_group_id

Type: belongs_to

Related object: L<ClinStudy::ORM::EmergentGroup>

=cut

__PACKAGE__->belongs_to(
  "emergent_group_id",
  "ClinStudy::ORM::EmergentGroup",
  { id => "emergent_group_id" },
);

=head2 visit_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IK8eVHZMPcoMKI40VW+zUQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
