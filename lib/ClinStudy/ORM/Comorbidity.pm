package ClinStudy::ORM::Comorbidity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

ClinStudy::ORM::Comorbidity

=cut

__PACKAGE__->table("comorbidity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 condition_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 date

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "condition_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "date",
  { data_type => "date", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 patient_id

Type: belongs_to

Related object: L<ClinStudy::ORM::Patient>

=cut

__PACKAGE__->belongs_to(
  "patient_id",
  "ClinStudy::ORM::Patient",
  { id => "patient_id" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-07-29 13:19:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d2ke/qHC6MdGFTXBklK59A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
