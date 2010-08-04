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

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Config::YAML;
use ClinStudy::ORM;
use List::Util qw(first);

sub parse_args {

    my ( $conffile, $class, $action, $field, $value, $where, $want_help );

    GetOptions(
        "c|config=s"       => \$conffile,
        "k|class=s"        => \$class,
        "f|field=s"        => \$field,
        "v|value=s"        => \$value,
        "a|action=s"       => \$action,
        "w|where=s"        => \$where,
        "h|help"           => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $class && $where && $action
                 && ( $action ne 'update' || ( $field && defined $value ) ) ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    unless ( first { lc $action eq $_ } qw(delete update) ) {
        die(qq{Action must be either "update" or "delete".\n});
    }

    my $config = Config::YAML->new(config => $conffile);

    # FIXME it might be better to do this by introspection, but assuming
    # the primary ID column is "id" will do for now.
    if ( $field && $field =~ /\A id \z/ixms ) {
        die("Error: Cannot update a primary ID column.");
    }

    return(  $config->{'Model::DB'}->{connect_info}, $class, lc $action, $where, $field, $value );
}

my ( $conn_params, $class, $action, $where, $field, $value ) = parse_args();

my $schema = ClinStudy::ORM->connect( @$conn_params );

my $obj_rs = $schema->resultset( $class )->search_literal( $where );

if ( $obj_rs->count() == 0 ) {
    die(qq{Error: No $class found with WHERE clause "$where".\n});
}

$schema->txn_do(
    sub {

        # DBIx::Class::Journal doesn't yet support RS-level updates
        # and deletes, so we have to iterate over rows.
        if ( $action eq 'update' ) {
            while ( my $obj = $obj_rs->next() ) {
                $obj->set_column( $field, $value );
                $obj->update();
            }
        }
        else {
            while ( my $obj = $obj_rs->next() ) {
                $obj->delete();
            }
        }
    }
);

print("$class objects WHERE $where successfully ${action}d.\n");

__END__

=head1 NAME

clinstudy_edit_data.pl

=head1 SYNOPSIS

 clinstudy_edit_data.pl -c <config file> -a <action> -k <ORM class>
             -w <WHERE clause> -f <update field> -v <update value>
 
 # Example:
 clinstudy_edit_data.pl -c clinstudy_web.yml
            -a update -k Patient -f trial_id -v T2000 -w 'id = 23'

=head1 DESCRIPTION

Trivial script which wraps a simple row-level update such that it is
entered into the database via the ORM layer. This is provided as a
very basic substitute for updating the database directly, and its sole
advantage is that it will maintain the integrity of the database audit
history.

Note that it is possible to do considerable damage to the database
using this script if you don't know what you're doing. However, the
audit history should always be available if you make a mistake.

=head2 OPTIONS

=over 2

=item -c

The YAML configuration file giving ClinStudy database connection parameters.

=item -a

The SQL action to invoke. Currently only "update" and "delete" are supported.

=item -k

The database ORM class being edited.

=item -w

An SQL WHERE clause to use to filter database table rows.

=item -f

The field to update (not required when deleting).

=item -v

The value to set the update field to (not required when deleting).

=back

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
