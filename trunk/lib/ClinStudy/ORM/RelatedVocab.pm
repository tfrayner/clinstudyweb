use utf8;
package ClinStudy::ORM::RelatedVocab;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::RelatedVocab

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<related_vocab>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<controlled_vocab_id>

=over 4

=item * L</controlled_vocab_id>

=item * L</target_id>

=item * L</relationship_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "controlled_vocab_id",
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

=head2 relationship_id

Type: belongs_to

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->belongs_to(
  "relationship_id",
  "ClinStudy::ORM::ControlledVocab",
  { id => "relationship_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4AljLqD1KHHQd2xSo+ZYVw


use overload '""' => sub { join(':', $_[0]->controlled_vocab_id,
                                $_[0]->relationship_id,
                                $_[0]->target_id ) }, fallback => 1;

1;
