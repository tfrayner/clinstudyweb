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

sub parse_args {

    my ( $conffile, $class, $id, $field, $value, $want_help );

    GetOptions(
        "c|config=s"       => \$conffile,
        "k|class=s"        => \$class,
        "i|id=s"           => \$id,
        "f|field=s"        => \$field,
        "v|value=s"        => \$value,        
        "h|help"           => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $class && defined $id && $field && defined $value ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    my $config = Config::YAML->new(config => $conffile);

    # FIXME it might be better to do this by introspection, but assuming
    # the primary ID column is "id" will do for now.
    if ( $id =~ /\A id \z/ixms ) {
        die("Error: Cannot update a primary ID column.");
    }

    return(  $config->{'Model::DB'}->{connect_info}, $class, $id, $field, $value );
}

my ( $conn_params, $class, $id, $field, $value ) = parse_args();

my $schema = ClinStudy::ORM->connect( @$conn_params );

my $obj = $schema->resultset($class)->find($id)
    or die("Error: Unable to find $class with ID $id.\n");

$schema->txn_do(
    sub {
        $obj->set_column( $field, $value );
        $obj->update();
    }
);

print("$class ($id) $field successfully set to $value.\n");

__END__

=head1 NAME

clinstudy_update_row.pl

=head1 SYNOPSIS

 clinstudy_update_row.pl -c <config file> -k <ORM class>
             -i <primary ID> -f <update field> -v <update value>

=head1 DESCRIPTION

Trivial script which wraps a simple row-level update such that it is
entered into the database via the ORM layer. This is provided as a
very basic substitute for updating the database directly, and its sole
advantage is that it will maintain the integrity of the database audit
history.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
