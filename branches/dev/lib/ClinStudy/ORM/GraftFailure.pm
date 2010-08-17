package ClinStudy::ORM::GraftFailure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::GraftFailure

=cut

__PACKAGE__->table("graft_failure");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 date

  data_type: 'date'
  is_nullable: 0

=head2 reason

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 transplant_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "date",
  { data_type => "date", is_nullable => 0 },
  "reason",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "transplant_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("transplant_id", ["transplant_id"]);

=head1 RELATIONS

=head2 transplant_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Transplant>

=cut

__PACKAGE__->belongs_to(
  "transplant_id",
  "ClinStudy::ORM::Transplant",
  { id => "transplant_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cAZj9RaU77Jf92SQ7ZRisQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
