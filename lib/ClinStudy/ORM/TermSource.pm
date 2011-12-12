use utf8;
package ClinStudy::ORM::TermSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::TermSource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<term_source>

=cut

__PACKAGE__->table("term_source");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 31

=head2 version

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 31 },
  "version",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 controlled_vocabs

Type: has_many

Related object: L<ClinStudy::ORM::ControlledVocab>

=cut

__PACKAGE__->has_many(
  "controlled_vocabs",
  "ClinStudy::ORM::ControlledVocab",
  { "foreign.term_source_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Xa1uqsZ3YpPK7SISmX3guw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
  "controlled_vocabs",
  "ClinStudy::ORM::ControlledVocab",
  { "foreign.term_source_id" => "self.id" },
  { "cascade_delete"     => 0 },
);

1;
