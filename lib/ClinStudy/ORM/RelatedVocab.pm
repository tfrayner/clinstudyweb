package ClinStudy::ORM::RelatedVocab;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("related_vocab");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "controlled_vocab_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "target_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "relationship_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "cv_relationship",
  ["controlled_vocab_id", "target_id", "relationship_id"],
);
__PACKAGE__->belongs_to(
  "controlled_vocab_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "controlled_vocab_id" },
);
__PACKAGE__->belongs_to(
  "target_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "target_id" },
);
__PACKAGE__->belongs_to(
  "relationship_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "relationship_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-04-23 10:31:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ev6TAmos11O6l9xdswANyA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
