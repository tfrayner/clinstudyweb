package ClinStudy::ORM::Assay;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::Assay

=cut

__PACKAGE__->table("assay");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 identifier

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 assay_batch_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 filename

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "identifier",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "assay_batch_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("identifier", ["identifier"]);
__PACKAGE__->add_unique_constraint("filename", ["filename"]);

=head1 RELATIONS

=head2 assay_batch_id

Type: belongs_to

Related object: L<ClinStudy::ORM::AssayBatch>

=cut

__PACKAGE__->belongs_to(
  "assay_batch_id",
  "ClinStudy::ORM::AssayBatch",
  { id => "assay_batch_id" },
);

=head2 assay_qc_values

Type: has_many

Related object: L<ClinStudy::ORM::AssayQcValue>

=cut

__PACKAGE__->has_many(
  "assay_qc_values",
  "ClinStudy::ORM::AssayQcValue",
  { "foreign.assay_id" => "self.id" },
  {},
);

=head2 channels

Type: has_many

Related object: L<ClinStudy::ORM::Channel>

=cut

__PACKAGE__->has_many(
  "channels",
  "ClinStudy::ORM::Channel",
  { "foreign.assay_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KNHov0fiE+xIl68LrG8eYQ


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
