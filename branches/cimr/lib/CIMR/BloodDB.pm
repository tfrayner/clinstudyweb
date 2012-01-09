use utf8;
package CIMR::BloodDB;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-11-21 13:48:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WK1lQzpEaXk3HfzIzbX/hg


# You can replace this text with custom content, and it will be preserved on regeneration
1;

=head1 NAME

CIMR::BloodDB - Local CIMR extension for interacting with blood test database.

=head1 SYNOPSIS

 use CIMR::BloodDB;
 my $schema = CIMR::BloodDB->connect(
     sprintf("dbi:SQLite:dbname=%s", $filename ),
 );

=head1 DESCRIPTION

This is an object-relational mapping (ORM) class, based on
DBIx::Class, used to connect to a local SQLite database containing
blood test results. These results will typically have been imported
from their original MS Access database file using
C<CIMR::AccessImporter>.

=head1 SEE ALSO

L<CIMR::AccessImporter>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

