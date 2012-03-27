use utf8;
package ClinStudy::ORM::GraftFailure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::GraftFailure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<graft_failure>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<transplant_id>

=over 4

=item * L</transplant_id>

=back

=cut

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


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/Z8KoEuRAoBpK3w1Zg+JZA

use overload '""' => sub { join(':', $_[0]->transplant_id, $_[0]->date) }, fallback => 1;

1;
