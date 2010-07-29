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
  "test_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "possible_value_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("test_id", "possible_value_id");

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9CLeheoR+/bPdtCyHLL2tQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;