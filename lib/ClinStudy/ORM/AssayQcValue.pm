use utf8;
package ClinStudy::ORM::AssayQcValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ClinStudy::ORM::AssayQcValue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<assay_qc_value>

=cut

__PACKAGE__->table("assay_qc_value");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 assay_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "assay_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=item * L</assay_id>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name", "assay_id"]);

=head1 RELATIONS

=head2 assay_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Assay>

=cut

__PACKAGE__->belongs_to("assay_id", "ClinStudy::ORM::Assay", { id => "assay_id" });


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-12 13:28:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hwGKr6GIN62qQ5NcUFFoqw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
