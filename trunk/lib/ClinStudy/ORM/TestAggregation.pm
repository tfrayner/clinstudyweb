package ClinStudy::ORM::TestAggregation;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("test_aggregation");
__PACKAGE__->add_columns(
  "aggregate_result_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "test_result_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("aggregate_result_id", "test_result_id");
__PACKAGE__->belongs_to(
  "aggregate_result_id",
  "ClinStudy::ORM::TestResult",
  { id => "aggregate_result_id" },
);
__PACKAGE__->belongs_to(
  "test_result_id",
  "ClinStudy::ORM::TestResult",
  { id => "test_result_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vd5oGyyMrPTCKJe0JIcRbw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
