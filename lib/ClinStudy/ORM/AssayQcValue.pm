package ClinStudy::ORM::AssayQcValue;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("assay_qc_value");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "value",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "type",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "assay_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name_assay", ["name", "assay_id"]);
__PACKAGE__->belongs_to("assay_id", "ClinStudy::ORM::Assay", { id => "assay_id" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:stfpp0kxRXUYWPaj9YjLoA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
