package ClinStudy::ORM::TestAggregation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::TestAggregation

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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "aggregate_test_result",
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-30 08:45:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DQXLXYNDdcyqy4UtZD09fg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
