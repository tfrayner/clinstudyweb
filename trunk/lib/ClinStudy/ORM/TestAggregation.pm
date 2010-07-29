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

=head2 aggregate_result_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 test_result_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "aggregate_result_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "test_result_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("aggregate_result_id", "test_result_id");

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zSlXRhukif1g8yt150qhCg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
