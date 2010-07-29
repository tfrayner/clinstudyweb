package ClinStudy::ORM::RelatedVocab;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::RelatedVocab

=cut

__PACKAGE__->table("related_vocab");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 controlled_vocab_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 target_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 relationship_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "controlled_vocab_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "target_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "relationship_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "cv_relationship",
  ["controlled_vocab_id", "target_id", "relationship_id"],
);

=head1 RELATIONS

=head2 controlled_vocab_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "controlled_vocab_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "controlled_vocab_id" },
);

=head2 target_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "target_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "target_id" },
);

=head2 relationship_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "relationship_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "relationship_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8Uxyz0Me0hOmZP6/scb3Uw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
