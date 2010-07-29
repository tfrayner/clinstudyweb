package ClinStudy::ORM::Channel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::Channel

=cut

__PACKAGE__->table("channel");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 label_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 assay_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "label_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "assay_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("assay_label", ["assay_id", "label_id"]);

=head1 RELATIONS

=head2 label_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "label_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "label_id" },
);

=head2 sample_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Sample>

=cut

__PACKAGE__->belongs_to("sample_id", "ClinStudy::ORM::Sample", { id => "sample_id" });

=head2 assay_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Assay>

=cut

__PACKAGE__->belongs_to("assay_id", "ClinStudy::ORM::Assay", { id => "assay_id" });


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:10WLcNRErD9SRvJqiG3bDg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
