use utf8;
package ClinStudy::ORM::TestAggregation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::TestAggregation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<test_aggregation>

=cut

__PACKAGE__->table("test_aggregation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 aggregate_result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 test_result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "aggregate_result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "test_result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<aggregate_result_id>

=over 4

=item * L</aggregate_result_id>

=item * L</test_result_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "aggregate_result_id",
  ["aggregate_result_id", "test_result_id"],
);

=head1 RELATIONS

=head2 aggregate_result_id

Type: belongs_to

Related object: L<ClinStudy::ORM::TestResult>

=cut

__PACKAGE__->belongs_to(
  "aggregate_result_id",
  "ClinStudy::ORM::TestResult",
  { id => "aggregate_result_id" },
);

=head2 test_result_id

Type: belongs_to

Related object: L<ClinStudy::ORM::TestResult>

=cut

__PACKAGE__->belongs_to(
  "test_result_id",
  "ClinStudy::ORM::TestResult",
  { id => "test_result_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:goasU29OVW2JEYJYtGzvkw

use overload '""' => sub { join(':', $_[0]->test_result_id,
                                $_[0]->aggregate_result_id) }, fallback => 1;

1;
