use utf8;
package ClinStudy::ORM::Test;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::Test

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<test>

=cut

__PACKAGE__->table("test");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
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

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 test_possible_values

Type: has_many

Related object: L<ClinStudy::ORM::TestPossibleValue>

=cut

__PACKAGE__->has_many(
  "test_possible_values",
  "ClinStudy::ORM::TestPossibleValue",
  { "foreign.test_id" => "self.id" },
  {},
);

=head2 test_results

Type: has_many

Related object: L<ClinStudy::ORM::TestResult>

=cut

__PACKAGE__->has_many(
  "test_results",
  "ClinStudy::ORM::TestResult",
  { "foreign.test_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v2YTodd7UBMX4uzdouYB3A


# You can replace this text with custom content, and it will be preserved on regeneration

# Custom has_many so that we track the cascade_delete behaviour of the
# database correctly (D::C::Schema::Loader doesn't do this yet). These
# relationships replace the autogenerated ones above, and the latter
# can be deleted when we're finally done with D::C::S::L). FIXME

__PACKAGE__->has_many(
  "test_results",
  "ClinStudy::ORM::TestResult",
  { "foreign.test_id" => "self.id" },
  { "cascade_delete"  => 0 },
);

# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:

# (NOTE that this is a one-way relationship, will need to add similar
# to ControlledVocab.pm if we ever want to navigate in the reverse
# direction).
__PACKAGE__->many_to_many(
    "possible_values" => "test_possible_values", "possible_value_id"
);

# Default stringification method.
use overload '""' => sub { shift->name }, fallback => 1;

1;
