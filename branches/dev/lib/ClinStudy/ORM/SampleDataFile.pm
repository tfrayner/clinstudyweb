package ClinStudy::ORM::SampleDataFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::SampleDataFile

=cut

__PACKAGE__->table("sample_data_file");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 filename

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "filename",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "notes",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("filename", ["filename"]);

=head1 RELATIONS

=head2 sample_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Sample>

=cut

__PACKAGE__->belongs_to("sample_id", "ClinStudy::ORM::Sample", { id => "sample_id" });

=head2 type_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "type_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "type_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2011-10-11 11:27:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8WDXqPy2PCKfxI5w0J7dGg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
