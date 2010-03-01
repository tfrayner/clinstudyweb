package ClinStudy::ORM::VisitEmergentGroup;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("visit_emergent_group");
__PACKAGE__->add_columns(
  "visit_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "emergent_group_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("visit_id", "emergent_group_id");
__PACKAGE__->belongs_to("visit_id", "ClinStudy::ORM::Visit", { id => "visit_id" });
__PACKAGE__->belongs_to(
  "emergent_group_id",
  "ClinStudy::ORM::EmergentGroup",
  { id => "emergent_group_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qNJOGs0NdDYnXBnBgfH/gQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
