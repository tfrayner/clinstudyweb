package ClinStudy::ORM::PatientPriorGroup;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("patient_prior_group");
__PACKAGE__->add_columns(
  "patient_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "prior_group_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("patient_id", "prior_group_id");
__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);
__PACKAGE__->belongs_to(
  "prior_group_id",
  "ClinStudy::ORM::PriorGroup",
  { id => "prior_group_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-26 11:28:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DpMDhosxl/QLLkgvHzYkzw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
