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

use strict;
use warnings;

package CIMR::Types;

use MooseX::Types::Moose qw( Object Str HashRef );
use MooseX::Types
    -declare => [ qw( Date ) ];

use DateTime;
use Params::Coerce;
use Carp;

subtype Date,

    as Object,
    where { UNIVERSAL::isa( $_, 'DateTime' ) };

coerce Date,

    from Object,
    via { UNIVERSAL::isa( $_, 'DateTime' )
                 ? $_
                 : Params::Coerce::coerce( 'DateTime', $_ ) },

    from HashRef,
    via {
        DateTime->new(%$_);
    },

    from Str,
    via {
        require DateTime::Format::DateManip;

        # We parse all dates as UTC.
        $ENV{'TZ'} = 'UTC';

        DateTime::Format::DateManip->parse_datetime($_)
            or croak(qq{Cannot parse date format "$_"; try YYYY-MM-DD});
    };

=pod

=head1 NAME

CIMR::Types - custom data types for CIMR

=head1 SYNOPSIS

 use CIMR::Types qw( Date );

=head1 DESCRIPTION

This class provides definitions and coercion methods for CIMR
data types not included as part of Moose. It is not intended to be
used directly.

=head1 TYPES

=over 2

=item Date

Dates are stored and retrieved as DateTime objects. Constructors and
mutators can be passed either a DateTime object, a hashref suitable
for passing to DateTime->new(), or a string date representation. In
the latter case this class attempts to parse the string into a
DateTime object using the Date::Manip module.

=back

=head1 SEE ALSO

DateTime, Date::Manip

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
