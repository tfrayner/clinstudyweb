package ClinStudy::ORM::TestPossibleValue;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("test_possible_value");
__PACKAGE__->add_columns(
  "test_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "possible_value_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("test_id", "possible_value_id");
__PACKAGE__->belongs_to("test_id", "ClinStudy::ORM::Test", { id => "test_id" });
__PACKAGE__->belongs_to(
  "possible_value_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "possible_value_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-26 11:03:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k/E40SrQ0tRn6yXfrhh58Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
