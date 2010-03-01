package ClinStudy::ORM::Assay;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("assay");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "identifier",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "assay_batch_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "filename",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "notes",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("identifier", ["identifier"]);
__PACKAGE__->add_unique_constraint("filename", ["filename"]);
__PACKAGE__->belongs_to(
  "assay_batch_id",
  "ClinStudy::ORM::AssayBatch",
  { id => "assay_batch_id" },
);
__PACKAGE__->has_many(
  "assay_qc_values",
  "ClinStudy::ORM::AssayQcValue",
  { "foreign.assay_id" => "self.id" },
);
__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.assay_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-23 13:53:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hrHtgvELMQYhlqmOFgOMQw


# You can replace this text with custom content, and it will be preserved on regeneration

# Channels do a cascade delete so we don't list them here.
__PACKAGE__->has_many(
  "assay_qc_values",
  "ClinStudy::ORM::AssayQcValue",
  { "foreign.assay_id" => "self.id" },
  { "cascade_delete"   => 0 },
);

__PACKAGE__->many_to_many(
    "samples" => "channels", "sample_id"
);

1;
