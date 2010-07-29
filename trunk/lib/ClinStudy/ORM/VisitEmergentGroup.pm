package ClinStudy::ORM::VisitEmergentGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::VisitEmergentGroup

=cut

__PACKAGE__->table("visit_emergent_group");

=head1 ACCESSORS

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
  "visit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "emergent_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("visit_id", "emergent_group_id");

=head1 RELATIONS

=head2 visit_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Visit>

=cut

__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });

=head2 emergent_group_id

Type: belongs_to

Related object: L<ClinStudy::ORM::EmergentGroup>

=cut

__PACKAGE__->belongs_to(
  "emergent_group_id",
  "ClinStudy::ORM::EmergentGroup",
  { id => "emergent_group_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0khYeFWx0KUR1yI6GsI01Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
