package ClinStudy::ORM::TestPossibleValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::TestPossibleValue

=cut

__PACKAGE__->table("test_possible_value");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 test_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 possible_value_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "test_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "possible_value_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("test_possible_value", ["test_id", "possible_value_id"]);

=head1 RELATIONS

=head2 test_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Test>

=cut

__PACKAGE__->belongs_to("test_id", "ClinStudy::ORM::Test", { id => "test_id" });

=head2 possible_value_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "possible_value_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "possible_value_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 21:47:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PjAH0hZw9Gr5BRTU1QL7Zg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
