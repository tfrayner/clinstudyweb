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

package MyBuilder;

use ClinStudy::XML::Builder;
use Moose;
extends 'ClinStudy::XML::Builder';

# Builder subclass just adds a few convenience methods; this is really
# only useful in cases where we can't just call
# $self->update_or_create_element directly (e.g. new_diagnosis).

sub new_visit {

    my ( $self, $vdate, $tpoint, $patient ) = @_;

    return( $self->update_or_create_element(
        'Visit',
        { date              => $vdate,
          nominal_timepoint => $tpoint },
        $patient ) );
}

sub new_patient {

    # Root is assumed to be the parent.
    my ( $self, $trial_id, $entry_date, $home_centre ) = @_;

    return( $self->update_or_create_element(
        'Patient',
        { trial_id    => $trial_id,
          entry_date  => $entry_date,
          home_centre => $home_centre } ) );
}

sub new_diagnosis {

    my ( $self, $disease, $patient ) = @_;

    return unless ( $disease && $disease !~ /\A (?:normal|unknown) \z/ixms );

    # Remap from our ARR conventions to ClinStudy terms.
    my %map = ('SLE' => 'Systemic Lupus Erythematosus');
    if ( my $new = $map{$disease} ) {
        $disease = $new;
    }

    return( $self->update_or_create_element(
        'Diagnosis',
        { condition_name => $disease },
        $patient ) );
}

sub new_sample {

    my ( $self, $name, $cell_type, $visit ) = @_;

    return( $self->update_or_create_element(
        'Sample',
        { name => $name,
          cell_type => $cell_type,
          material_type => 'RNA' },
        $visit ) );
}

sub new_assay_batch {

    # Root is assumed to be the parent.
    my ( $self, $date, $name, $operator ) = @_;

    return( $self->update_or_create_element(
        'AssayBatch',
        { date     => $date,
          name     => $name,
          platform => 'Affymetrix',
          operator => $operator } ) );
}

sub new_channel {

    my ( $self, $sample, $assay ) = @_;

    return( $self->update_or_create_element(
        'Channel',
        { sample_ref => $sample,
          label      => 'biotin' },
        $assay ) );
}

sub new_assay {

    my ( $self, $assay_id, $file, $batch ) = @_;

    return( $self->update_or_create_element(
        'Assay',
        { identifier => $assay_id,
          filename   => $file },
        $batch ) );
}

sub new_assay_qc {

    my ( $self, $name, $value, $assay ) = @_;

    return unless ( defined $value && $value ne q{} );

    return( $self->update_or_create_element(
        'AssayQcValue',
        { name => $name,
          value => $value },
        $assay ) );
}

package main;

use Getopt::Long;
use Date::Calc qw(Date_to_Days);
use Config::YAML;
use ClinStudy::ORM;
use CIMR::Parser::ARR;

sub retrieve_visit {

    # Slightly fuzzy matching of visit dates, to within 4
    # days. Returns the found visit or undef on failure.
    my ( $patient, $bleed_date, $schema ) = @_;

    unless ( $patient && $bleed_date ) {
        return;   # If no patient, ergo no visit.
    }

    unless ( UNIVERSAL::isa( $bleed_date, 'DateTime' ) ) {
        die("Error: was expecting a DateTime object.");
    }

    my $visit = $schema->resultset('Visit')->find({
        patient_id => $patient->id(),
        date       => $bleed_date,
    });
    
    return $visit if $visit;

    my $candidate;
    my $best;
    foreach my $visit ( $patient->visits() ) {
        my $vdate = $visit->date();
        my ( $y, $m, $d ) = ( $vdate =~ /\A (\d{4}) - (\d{2}) - (\d{2}) \z/xms );
        my $diff = abs(Date_to_Days( $y, $m, $d )
                     - Date_to_Days( $bleed_date->year,
                                     $bleed_date->month,
                                     $bleed_date->day, ));

        # Arbitrary threshold. Try and match as close as possible.
        if ( $diff < 4 && ( ! defined $best || $diff < $best ) ) {
            $candidate = $visit;
            $best      = $diff;
        }
    }

    if ( defined $candidate ) {
        warn(sprintf("Matching ARR file bleed date %s to nearby visit date %s.\n",
                     $bleed_date, $candidate->date));
        return $candidate;
    }

    return;
}

sub retrieve_sample {

    my ( $cell_type, $visit, $schema ) = @_;

    return unless ( $visit && $cell_type );

    my $celltype = $schema->resultset('ControlledVocab')->find({
        category => 'CellType',
        value    => $cell_type,
    }) or die("Error: Cell type not found in database: $cell_type.\n");

    my $material = $schema->resultset('ControlledVocab')->find({
        category => 'MaterialType',
        value    => 'RNA',
    }) or die("Error: RNA MaterialType is not found in the database.\n");

    my $sample = $schema->resultset('Sample')->find({
        visit_id         => $visit->id(),
        cell_type_id     => $celltype->id(),
        material_type_id => $material->id(),
    });

    return $sample;
}

sub latest_diagnosis {

    my ( $patient ) = @_;

    return unless $patient;

    my @diagnoses = $patient->diagnoses;

    return unless @diagnoses;

    my @sorted = reverse sort { $a->date cmp $b->date } @diagnoses;

    return $sorted[0]->condition_name_id->value;
}

sub import_arr_file {

    my ( $file, $builder, $schema ) = @_;

    # Parse the ARR file.
    my $arr = CIMR::Parser::ARR->new(
        arr_file => $file,
    );
    my $attr = $arr->user_attributes();

    # Check the ARR file contains the requisite info.
    unless ( defined $attr->{patient_number} ) {
        warn("Warning: Patient number not defined in ARR file.\n");
        return;
    }
    unless ( $attr->{bleed_date} ) {
        warn("Warning: Bleed date not defined in ARR file.\n");
        return;
    }
    unless ( $attr->{cell_type} ) {
        warn("Warning: Cell type not defined in ARR file.\n");
        return;
    }

    # Retrieve whatever info we can from the database.
    my $db_patient = $schema->resultset('Patient')->find({trial_id => $attr->{patient_number}});
    my $db_visit   = retrieve_visit( $db_patient, $attr->{bleed_date}, $schema );
    my $db_sample  = retrieve_sample( $attr->{'cell_type'}, $db_visit, $schema );

    # Set some variables based upon what we find.
    my $tp = $attr->{time_point};
    my $vdate  = $db_visit ? $db_visit->date() : $attr->{bleed_date};
    $vdate = substr( $vdate, 0, 10 );
    my $tpoint = ($db_visit && $db_visit->nominal_timepoint_id()) ? $db_visit->nominal_timepoint_id->value()
               : ! length($tp) ? q{}
               : $tp eq '1' ? "$tp month"
               : "$tp months";
    my $disease_state = latest_diagnosis( $db_patient ) || $attr->{disease_state};

    # Create patient node.
    my ( $entry_date, $home_centre );
    if ( $db_patient ) {
        $entry_date = $db_patient->entry_date();
        if ( my $centre = $db_patient->home_centre_id() ) {
            $home_centre = $centre->value;
        }
    }
    elsif ( defined $tp && $tp eq '0') {
        warn("Setting entry_date from time zero visit (patient $attr->{patient_number}).\n");
        $entry_date = $vdate;
    }
    else {
        warn("WARNING: no entry_date available for patient $attr->{patient_number}\n");
    }

    $home_centre ||= $attr->{cohort};

    my $patient   = $builder->new_patient( $attr->{patient_number}, $entry_date, $home_centre );
    my $diagnosis = $builder->new_diagnosis( $disease_state, $patient );

    # Create Visit node.
    my $visit     = $builder->new_visit( $vdate, $tpoint, $patient );

    # Create Sample node.
    my $sample_name;
    if ( $db_sample ) {
        $sample_name = $db_sample->name();
    }
    else {
        $sample_name = join(' ', $attr->{'patient_number'}, $attr->{'cell_type'}, $vdate);
    }

    my $sample = $builder->new_sample( $sample_name, $attr->{'cell_type'}, $visit );

    # Create AssayBatch node.

    # We need to substring date here so we don't confuse poor MySQL
    # and the XML schema. We use scan_date because it's the most
    # reliable of the available dates, but it comes in
    # YYYY-MM-DDTHH:MM:SSZ format which is overkill.
    my $adate = substr( $arr->scan_date(), 0, 10);
    my $batch = $builder->new_assay_batch( $adate, $arr->batch_name(), $arr->operator() );
        
    # Create Assay node.  We're casually assuming here that this is
    # the *only* place that affy assay identifiers are set.
    my $assay_id = sprintf(
        "%s: %s",
        $adate,
        $sample_name,
    );
    my $assay = $builder->new_assay( $assay_id, $arr->cel_file(), $batch );

    # Create QC nodes
    my @qc = grep { /^cRNA|ssDNA/ } keys %{ $attr };
    foreach my $qc_attr ( @qc ) {
        my $value = $attr->{$qc_attr};
        if ( defined $value ) {

            # FIXME it would be nice to get type info in here as well.
            my $qc = $builder->new_assay_qc( $qc_attr, $value, $assay );
        }
    }

    # Create Channel node.
    my $channel = $builder->new_channel( $sample_name, $assay );
    
    return;
}

# Parse command-line options.
my ( $conffile, $xsd, $relaxed );
GetOptions(
    "c|config=s" => \$conffile,
    "d|schema=s" => \$xsd,
    "r|relaxed"  => \$relaxed,
);

unless ( $conffile && $xsd && scalar @ARGV ) {

    print (<<"USAGE");

Usage: $0 -c <config file> -d <XML schema file> <list of ARR files>

Optional: -r Output XML without checking for validity.

USAGE

    exit 255;
}

# Connect to the database.
my $conf = Config::YAML->new( config => $conffile );
my $connect_info = $conf->{'Model::DB'}->{connect_info};
my $schema = ClinStudy::ORM->connect( @$connect_info );

my $builder = MyBuilder->new(
    schema_file => $xsd,
    is_strict   => ! $relaxed,
);

foreach my $file ( @ARGV ) {

    # This populates $builder with elements.
    import_arr_file($file, $builder, $schema);
}

$builder->dump();
