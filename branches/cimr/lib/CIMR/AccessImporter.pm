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

package CIMR::AccessImporter;

use File::Temp qw(tempfile);
use SQL::Translator;

use base qw(Exporter);
our @EXPORT_OK = qw(
                       import_schema
                       import_data
               );

sub clean_sql {

    my ( $sql ) = @_;

    # Strip leading and trailing underscores from everything.
    $sql =~ s/\b_*(\w+?)_*\b/$1/g;

    # Reduce long sets of underscores to just one.
    $sql =~ s/__+/_/g;

    # Quote words which begin with a digit.
    $sql =~ s/\b(\d+[a-zA-Z]\w+)/\'$1\'/g;

    # Remove any truly odd characters (FIXME no utf8 support here yet!)
    $sql =~ s/[[:^ascii:]]//;

    return $sql;
}

sub import_schema {

    my ( $db_file, $out_file ) = @_;

    # Dump what we can from the Access DB.
    my ( $tmpfh, $tmpfile ) = tempfile();
    system(qq{mdb-schema -S "$db_file" postgres > $tmpfile}) == 0
        or die("Access schema export failed: $@");

    # Preprocess the output from mdb-schema so that unknown fields don't confuse SQL::Translator
    my ( $tmp3fh, $tmp3file ) = tempfile();
    while ( my $sql = <$tmpfh> ) {
        $sql =~ s/Postgres_Unknown 0x10/Numeric \(9\)/g;   # This I'm sure of...
        $sql =~ s/Postgres_Unknown 0x09/Char \(100\)/g;    # This I'm not.

        # FIXME consider a catchall here.

        print $tmp3fh $sql;
    }
    seek($tmp3fh, 0, 0);

    # Convert the SQL to SQLite form.
    my $translator = SQL::Translator->new(
        quote_table_names => 1,
        quote_field_names => 1,
        validate          => 1,
    );
    my $sql = $translator->translate(
        from     => 'PostgreSQL',
        to       => 'SQLite',
        filename => $tmp3file,
    ) or die( $translator->error() );

    # Clean up some of the odder features.
    $sql = clean_sql( $sql );

    # Load the SQL into the nascent database.
    my ( $tmp2fh, $tmp2file ) = tempfile();
    print $tmp2fh $sql;
    system(qq{sqlite3 "$out_file" < $tmp2file}) == 0
        or die("SQLite database creation failed: $@");

    return;
}

sub import_data {

    my ( $db_file, $out_file ) = @_;
    
    # Get a list of Access tables.
    open( my $tab_fh, '-|', qq{mdb-tables "$db_file"} )
        or die("Error: unable to open piped input from mdb-tables command.");
    my @tables = grep { $_ =~ /\S/ } split / /, <$tab_fh>;

    foreach my $table ( @tables ) {

        # Dump the data as insert statements.
        my ( $tmpfh, $tmpfile ) = tempfile();
        system(qq{mdb-export -S -I -R ';\n' "$db_file" "$table" > $tmpfile}) == 0
            or die("Access data export failed: $@");

        # Clean up the statements.
        seek( $tmpfh, 0, 0) or die($!);
        my ( $tmp2fh, $tmp2file ) = tempfile();
        my $totalsql;
        while ( my $sql = <$tmpfh> ) {
            $sql = clean_sql( $sql );
            $sql =~ s/[[:cntrl:]]//g;   # An additional precaution for the insert statements.
            print $tmp2fh $sql;
            $totalsql .= $sql;
        }

        # Load them into the SQLite database.
        system(qq{sqlite3 "$out_file" < $tmp2file}) == 0
            or die("SQLite data insertion failed: $@");
    }

    return;
}

1;

__END__

=head1 NAME

CIMR::AccessImporter - Perl extension for converting MS Access databases to SQLite.

=head1 SYNOPSIS

 use CIMR::AccessImporter qw(import_schema import_data);
 
 import_schema( $access_file, $sqlite_file );
 import_data( $access_file, $sqlite_file );

=head1 DESCRIPTION

This is a simple Perl Exporter module which provides functions that
can be called to take data from a MS Access database file (*.mdb) and
import it into a SQLite database. The output database can either be
created from scratch or updated with data from the input database.

Behind the scenes this module relies heavily on the MDB Tools package,
available from http://mdbtools.sourceforge.net/ for Unix-like OSen.

=head1 EXPORT

None by default. Optional exports include:

=head2 import_schema( $access, $sqlite )

Imports just the database schema from an Access database file into a
SQLite file. The latter will be created automatically if not already
present.

=head2 import_data( $access, $sqlite )

Imports just the data from the Access file into a SQLite file. The
latter must have been preloaded with a compatible database schema (see
C<import_schema>, above).

=head2 clean_sql( $sql )

Takes a string containing SQL statements, and performs a handful of
operations to clean it up:

=over 2

=item Strip leading and trailing underscores from everything.

=item Reduce long sets of underscores to just one.

=item Quote words which begin with a digit.

=item Remove any non-ASCII characters (Unicode not yet supported).

=back

=head1 SEE ALSO

http://mdbtools.sourceforge.net/

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

