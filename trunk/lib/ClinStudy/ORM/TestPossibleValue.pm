use utf8;
package ClinStudy::ORM::TestPossibleValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::TestPossibleValue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<test_possible_value>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<test_id>

=over 4

=item * L</test_id>

=item * L</possible_value_id>

=back

=cut

__PACKAGE__->add_unique_constraint("test_id", ["test_id", "possible_value_id"]);

=head1 RELATIONS

=head2 possible_value_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "possible_value_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "possible_value_id" },
);

=head2 test_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Test>

=cut

__PACKAGE__->belongs_to("test_id", "ClinStudy::ORM::Test", { id => "test_id" });


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NC063OQ4p7LgI8IQSx9dVQ


use overload '""' => sub { join(':', $_[0]->test_id, $_[0]->possible_value_id) }, fallback => 1;

1;
