#!/usr/bin/env perl
# 
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
#
package CSWTestLib;

use 5.008;

use strict; 
use warnings;

use Carp;

use Data::Dumper;

use File::Copy;

BEGIN {
    $ENV{CLINSTUDY_WEB_CONFIG} = 'clinstudy_web_testing.yml';
    copy('t/pristine_testing.db', 't/testing.db');
};

1;
__END__

=head1 NAME

CSWTestLib - Test library for use with ClinStudyWeb

=head1 SYNOPSIS

 use CSWTestLib;

=head1 DESCRIPTION

This library is part of the test suite for ClinStudyWeb.

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut
