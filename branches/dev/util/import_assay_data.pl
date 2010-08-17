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
use Text::CSV_XS;
use Pod::Usage;

use ClinStudy::XML::Builder;
use ClinStudy::ORM;
use Config::YAML;

sub import_assays {

    my ( $file, $schema, $builder ) = @_;

    my $csv = Text::CSV_XS->new({
        eol      => "\n",
        sep_char => "\t",
    });

    open ( my $fh, '<', $file )
        or die("Error: unable to open file $file");

    # Header line must be the first line in the file.
    my $header = $csv->getline($fh);

    LINE:
    while ( my $larry = $csv->getline($fh) ) {

        # Skip empty and commented lines.
        next LINE if ( scalar @$larry < 1 || $larry->[0] =~ /\A \s* \#/xms );

        my %row;
        @row{ @$header } = @$larry;

        # We need both a sample and a date.
        next LINE unless ( length $row{'sample'} && length $row{'date'} );

        next LINE if ( $row{'sample'} =~ /\A na \z/ixms );

        my $db_sample = $schema->resultset('Sample')->find({
            name => $row{'sample'},
        });

        unless ( $db_sample ) {
            die("Error: unable to find sample $row{sample}.\n");
        }

        # A couple of quick consistency checks.
        unless ( lc $db_sample->cell_type_id->value eq lc $row{'cd'} ) {
            warn("WARNING: cell types do not match for $row{'array'}\n");
        }
        unless ( lc $db_sample->visit_id->patient_id->trial_id eq lc $row{'patient_no'} ) {
            warn("WARNING: patient identifiers do not match for $row{'array'}\n");
        }

        # We take everything from sample upwards from the database.
        my $db_visit   = $db_sample->visit_id();
        my $db_patient = $db_visit->patient_id();
        my $patient = $builder->update_or_create_element(
            'Patient',
            { trial_id   => $db_patient->trial_id,
              entry_date => $db_patient->entry_date });

        my $visit   = $builder->update_or_create_element(
            'Visit',
            { date => $db_visit->date },
            $patient);

        my $sample  = $builder->update_or_create_element(
            'Sample',
            { name => $db_sample->name,
              cell_type => $db_sample->cell_type_id->value,
              material_type => $db_sample->material_type_id->value },
            $visit);

        # This is the new stuff.
        my $batch = $builder->update_or_create_element(
            'AssayBatch',
            { date     => $row{'date'},
              platform => 'MEDIANTE',
              name     => "MEDIANTE $row{date}"});

        my $assay = $builder->update_or_create_element(
            'Assay',
            { identifier     => $row{'array'},
              notes          => $row{'comments'} }, $batch);

        unless ( $row{'channel'} =~ m/\A cy[35] /xms ) {
            $row{'channel'} = "Cy$row{channel}";
        }

        my $channel = $builder->update_or_create_element(
            'Channel',
            { label      => $row{'channel'},
              sample_ref => $db_sample->name() },
            $assay);
    }

    my ( $error, $mess ) = $csv->error_diag();
    unless ( $error == 2012 ) {    # 2012 is the Text::CSV_XS EOF code.
	die(
	    sprintf(
		"Error in tab-delimited format: %s. Bad input was:\n\n%s\n",
		$mess,
		$csv->error_input(),
	    ),
	);
    }

    return;
}

sub parse_args {

    # Parse command-line options.
    my ( $conffile, $spreadsheet, $xsd, $relaxed, $want_help );
    GetOptions(
        "c|config=s" => \$conffile,
        "f|file=s"   => \$spreadsheet,
        "d|schema=s" => \$xsd,
        "r|relaxed"  => \$relaxed,
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $conffile && $spreadsheet && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    return( $conffile, $spreadsheet, $xsd, $relaxed );
}

my ( $conffile, $spreadsheet, $xsd, $relaxed ) = parse_args();

# Connect to the database.
my $config = Config::YAML->new( config => $conffile );
my $connect_info = $config->{'Model::DB'}->{'connect_info'};
my $schema = ClinStudy::ORM->connect( @$connect_info );
my $builder = ClinStudy::XML::Builder->new(
    schema_file => $xsd,
    is_strict   => ! $relaxed,
);

import_assays($spreadsheet, $schema, $builder);

$builder->dump();

__END__

=head1 NAME

import_assay_data.pl

=head1 SYNOPSIS

 import_assay_data.pl -c <config file> -d <XML schema file> -f <assay spreadsheet>

=head1 DESCRIPTION

Script to convert the old MEDIANTE assay records into ClinStudyML
format for loading into the database.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
