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

# This is a parent class for all TestCalc modules.

package ClinStudy::Web::TestCalc;

use strict;
use warnings;

use Moose;

sub check_result_existence {

    my ( $self, $schema, $container, $testname ) = @_;

    my $test   = $schema->resultset('Test')->find({ name => $testname })
        or die(qq{Test "$testname" not found in database\n});

    my $count = $container->search_related(
        'test_results',
        {'test_id.name' => $_ },
        { join     => 'test_id', prefetch => 'test_id' })->count();

    return $count;
}

__PACKAGE__->meta->make_immutable();

no Moose;

1;
