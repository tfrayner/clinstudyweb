# Copyright 2010 Tim Rayner, University of Cambridge
# 
# This file is part of ClinStudy::Web.
# 
# ClinStudy::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# ClinStudy::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package ClinStudy::Web::Model::DB;

use strict;
use warnings;

use base 'Catalyst::Model::DBIC::Schema';

# Database connection is now set in the main ClinStudy::Web config file.
__PACKAGE__->config(

  # Static external schema.
  schema_class => 'ClinStudy::ORM',

  # Dynamic internal schema.
#  schema_class => 'ClinStudy::Web::Schema',

);

=head1 NAME

ClinStudy::Web::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<ClinStudy::Web>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<ClinStudy::Web::Schema>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
