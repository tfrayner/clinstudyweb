package ClinStudy::ORM::TestResult;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("test_result");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "test_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "visit_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "hospitalisation_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "value",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "controlled_value_id",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "date",
  { data_type => "DATE", default_value => undef, is_nullable => 0, size => 10 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("test_result_visit_id", ["test_id", "date", "visit_id"]);
__PACKAGE__->add_unique_constraint(
  "test_result_hospitalisation_id",
  ["test_id", "date", "hospitalisation_id"],
);
__PACKAGE__->has_many(
  "test_aggregation_aggregate_result_ids",
  "ClinStudy::ORM::TestAggregation",
  { "foreign.aggregate_result_id" => "self.id" },
);
__PACKAGE__->has_many(
  "test_aggregation_test_result_ids",
  "ClinStudy::ORM::TestAggregation",
  { "foreign.test_result_id" => "self.id" },
);
__PACKAGE__->belongs_to("test_id", "ClinStudy::ORM::Test", { id => "test_id" });
__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });
__PACKAGE__->belongs_to(
  "hospitalisation_id",
  "ClinStudy::ORM::Hospitalisation",
  { id => "hospitalisation_id" },
);
__PACKAGE__->belongs_to(
  "controlled_value_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "controlled_value_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-09 16:38:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3ZFSPUHS6204FU/AKXRNGQ


# You can replace this text with custom content, and it will be preserved on regeneration

# This cascading delete is only allowed from the child result, not the
# parent. FIXME note the custom relationship name here, to be used in
# preference to the autogenerated name above which will one day be
# deleted.
__PACKAGE__->has_many(
  "child_test_result_ids",
  "ClinStudy::ORM::TestAggregation",
  { "foreign.aggregate_result_id" => "self.id" },
  { "cascade_delete"   => 0 },
);

# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:
__PACKAGE__->many_to_many(
    "parent_test_results" => "test_aggregation_test_result_ids", "aggregate_result_id",
  { "cascade_delete"   => 0 },
);
__PACKAGE__->many_to_many(
    "child_test_results" => "child_test_result_ids", "test_result_id",
  { "cascade_delete"   => 0 },
);

1;
