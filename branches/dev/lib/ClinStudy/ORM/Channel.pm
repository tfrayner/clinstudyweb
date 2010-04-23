package ClinStudy::ORM::Channel;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("channel");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "label_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "sample_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "assay_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("assay_label", ["assay_id", "label_id"]);
__PACKAGE__->belongs_to(
  "label_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "label_id" },
);
__PACKAGE__->belongs_to("sample_id", "ClinStudy::ORM::Sample", { id => "sample_id" });
__PACKAGE__->belongs_to("assay_id", "ClinStudy::ORM::Assay", { id => "assay_id" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fg4Qz1f28XqCuAcEPv0HqQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
