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

has 'database' => ( is       => 'ro',
                    isa      => 'DBIx::Class::Schema',
                    required => 1 );

has 'auto_create_implied_samples' => ( is       => 'ro',
                                       isa      => 'Bool',
                                       required => 1,
                                       default  => 1 );

use Carp;
use Spreadsheet::ParseExcel;
use List::Util qw(min);
use Readonly;

use ClinStudy::ORM;
use CIMR::SheetIterator;
use Config::YAML;

# Controlled vocab for column headings, used to avoid us missing
# anything if Alex decides to change the spreadsheet format.
Readonly my $PNAME       => 'patient name';
Readonly my $PNUM        => 'patient number';
Readonly my $HNUM        => 'hospital number';
Readonly my $BLEEDDAT    => 'Date of bleed';
Readonly my $TPOINT      => 'time point';
Readonly my $DISEASE     => 'Disease';
Readonly my $DOB         => 'Date of birth';
Readonly my $CELLTYPE    => 'cell type';
Readonly my $MATERIAL    => 'material type';  # internal to this script
Readonly my $TNUM        => 'T number';
Readonly my $CONC        => 'RNA conc.(ng)';
Readonly my $PURITY      => '260/280nm';
Readonly my $BOX         => 'box';
Readonly my $LOCATION    => 'location';

sub update_patient_name {

    my ( $self, $patient_info, $name ) = @_;

    return unless $name;

    my @names = split / +/, $name;

    my $lname = $names[-1];
    my $fname = join(q{ }, @names[0..$#names-1]);

    # Anonymity prevails; we now discard the names.

    return;
}

sub update_patient_dob {

    my ( $self, $patient_info, $dob ) = @_;

    return unless $dob;

    my ( $d, $m, $y ) = ( $dob =~ m!\A (\d{2})-(\d{2})-(\d{4}) \z!xms );

    unless ( $d && $m && $y ) {
        warn("Warning: unparseable DOB: $dob.\n");
        return;
    }

    # Anonymity prevails; we now only use the year of birth, rather
    # than the entire date.
    $patient_info->{year_of_birth} = $y;

    return;
}

sub update_patient_hospital_id {

    my ( $self, $patient_info, $id ) = @_;

    return unless $id;

    # Anonymity prevails; we no longer store these.

    return;
}

sub update_patient_entrydate {

    my ( $self, $patient_info, $date ) = @_;

    return unless $date;

    $patient_info->{entry_date} = $date;

    return;
}

sub update_patient_gender {

    my ( $self, $patient_info, $gender ) = @_;

    return unless $gender;

    $gender = ( $gender eq 'male'   ? 'M'
              : $gender eq 'female' ? 'F'
              : undef );

    $patient_info->{sex} = $gender;

    return;
}

sub check_iterator {

    my ( $self, $iter, $expected ) = @_;

    my @headers = @{ $iter->header() };

    my $max = min( $#headers, $#$expected );
    for ( my $i = 0; $i <= $max; $i++ ) {
        unless( $expected->[$i] eq $headers[$i] ) {
            die("Error: Unexpected header row: " . join("; ", @headers) . "\n");
        }
    }
}

sub find_or_create_patient {

    my ( $self, $data, $date ) = @_;

    my $id = $data->{$PNUM};

    # Strip off any trailing "a" characters. These would typically
    # denote trial re-entry, but that's already being tracked by the
    # nominal timepoints.
    $id =~ s/a\z//ixms;
    return unless $id;

    # Try and deduce the entry date. Note that for the initial import
    # this needs the time zero visit to come first.
    my $entrydate;
    if ( defined $data->{$TPOINT} && $data->{$TPOINT} =~ /\A 0 \b/xms ) {
        $entrydate = $date;
    }

    # We only want to create attributes which aren't already in
    # the database, because this spreadsheet is not the most
    # precisely maintained beast.
    my %patient_info = ( trial_id   => $id,
                         entry_date => $entrydate );
    my $db_patient = $self->database->resultset('Patient')->find(\%patient_info);

    unless ( $db_patient ) {
        warn("Patient $id with entry date $entrydate not found in DB; creating new patient.\n");
    }

    # Update patient name (NB now we do not - anonymity prevails).

    # Update patient entry date.
    $self->update_patient_entrydate( \%patient_info, $db_patient->entry_date )
        if $db_patient;
    
    # Update patient DOB.
    unless ( $db_patient && $db_patient->year_of_birth() ) {
        $self->update_patient_dob( \%patient_info, $data->{$DOB} );
    }
    
    # Update patient Hospital Number (NB now we do not - anonymity prevails).

    # Update patient gender.
    unless ( $db_patient && $db_patient->sex() ) {
        if ( my $notes = $data->{'notes'} ) {
            my ( $gender ) = ( $notes =~ m/((?:fe)?male)/ixms );
            $self->update_patient_gender( \%patient_info, lc($gender) );
        }
    }

    my $patient = $self->update_or_create_element( 'Patient', \%patient_info );

    # Update patient diagnosis.
    my $diagnosis = $data->{$DISEASE};
    if ( $diagnosis ) {
        my @diseases  = $db_patient ? $db_patient->diagnoses() : ();
        unless ( scalar @diseases || $diagnosis =~ m/\A normal|control \z/ixms) {
            $self->update_or_create_element(
                'Diagnosis',
                { condition_name => $diagnosis },
                $patient);        
        }
    }

    return $patient;
}

sub find_or_create_visit {

    my ( $self, $patient, $date, $tp ) = @_;

    # Create the visit.
    my $visit = $self->update_or_create_element(
        'Visit',
        { date => $date },
        $patient );

    # Pull out some stuff from the database.
    my $trial_id = $patient->getAttribute('trial_id');
    my $db_visit = $self->retrieve_visit( $date, $trial_id )
        or warn("No DB visit for patient $trial_id on $date; creating new visit.\n");

    # Update visit nominal timepoint.
    unless ( $db_visit && $db_visit->nominal_timepoint_id() ) {
        $visit->setAttribute('nominal_timepoint', $tp) if defined $tp;
    }

    return $visit;
}

sub retrieve_visit {

    my ( $self, $date, $trial_id ) = @_;

    my $db_visit;
    my $db_patient = $self->database->resultset('Patient')->find({
        trial_id => $trial_id,
    });
    if ( $db_patient ) {
        $db_visit = $self->database->resultset('Visit')->find({
            patient_id => $db_patient->id,
            date       => $date,
        });
    }

    return $db_visit;
}

sub find_or_create_sample {

    my ( $self, $rowhash, $visit ) = @_;

    my $changes = 0;

    my $name          = $rowhash->{$TNUM};
    my $cell_type     = $rowhash->{$CELLTYPE};
    my $material_type = $rowhash->{$MATERIAL};

    my $date     = $visit->getAttribute('date');
    my $trial_id = $visit->parentNode->parentNode->getAttribute('trial_id');

    my $db_visit = $self->retrieve_visit( $date, $trial_id );

    # Check the sample types attached to $db_visit first,
    # since the names may have changed.
    my $mt = $self->database->resultset('ControlledVocab')->find({ category => 'MaterialType',
                                                                   value    => $material_type });
    my $ct = $self->database->resultset('ControlledVocab')->find({ category => 'CellType',
                                                                   value    => $cell_type });

    my $db_sample;
    if ( $mt && $ct ) {
        my @db_samples = $db_visit
                       ? $db_visit->search_related('samples', { cell_type_id     => $ct->id,
                                                                material_type_id => $mt->id })
                       : ();

        # Hopefully there will only ever be 0 or 1; more than one means we have to choose.
        if ( scalar @db_samples ) {
            if ( my @wanted = grep { $_->name eq $name } @db_samples ) {

                # Found a sample with the desired name.
                $db_sample = $wanted[0];
            }
            else {

                # No sample with the correct name; but then it may
                # well be wrong. We just take the first sample with
                # the correct cell and material type in such cases
                # (FIXME there will generally only be one; but this is
                # still a hack).
                $db_sample = $db_samples[0];
            }
        }
    }
    else {
        warn("Warning: Unknown cell or material type found in spreadsheet.\n");
    }

    # Extract name from the database if the sample exists.
    if ( $db_sample ) {
        $name = $db_sample->name;
    }
    else {
        $changes++;  # No db sample found means this is new information.
    }

    my $sample = $self->update_or_create_element(
        'Sample',
        { name          => $name,
          cell_type     => $cell_type,
          material_type => $material_type },
        $visit );

    # Only update these attributes if they're not already in the database.
    unless ( $db_sample && defined $db_sample->freezer_box ) {
        if ( $self->not_null($rowhash->{$BOX}) ) {
            $sample->setAttribute('freezer_box', $rowhash->{$BOX});
            $changes++;
        }
    }
    unless ( $db_sample && defined $db_sample->box_slot ) {
        if ( $self->not_null($rowhash->{$LOCATION}) ) {
            $sample->setAttribute('box_slot', $rowhash->{$LOCATION});
            $changes++;
        }
    }
    unless ( $db_sample && defined $db_sample->concentration ) {
        if ( $self->not_null($rowhash->{$CONC}) ) {
            $sample->setAttribute('concentration', $rowhash->{$CONC});
            $changes++;
        }
    }
    unless ( $db_sample && defined $db_sample->purity ) {
        if ( $self->not_null($rowhash->{$PURITY}) ) {
            $sample->setAttribute('purity', $rowhash->{$PURITY});
            $changes++;
        }
    }

    if ( $changes ) {
        return $sample;
    }
    else {
        $sample->unbindNode();  # No new info means dump the node.
        return;
    }
}

sub import_bleed_dates {

    my ( $self, $sheet ) = @_;

    my $iter = CIMR::SheetIterator->new( sheet => $sheet );

    my @expected = (
        $PNUM,
        $PNAME,
        $HNUM,
        $BLEEDDAT,
        $TPOINT,
        $DISEASE,
        $DOB,
    );

    $self->check_iterator($iter, \@expected);

    BLEED:
    while ( my $rowhash = $iter->next() ) {

        next BLEED unless $rowhash->{$PNUM};

        my $date = $self->parse_bleed_date( $rowhash->{$BLEEDDAT} )
            or croak("Error: Unparseable bleed date $rowhash->{$BLEEDDAT}");

        my $patient = $self->find_or_create_patient( $rowhash, $date )
            or next BLEED;

        my $tp = $rowhash->{$TPOINT};
        $tp .= ($tp eq '1' ? ' month' : ' months') if defined $tp;
        my $visit = $self->find_or_create_visit( $patient, $date, $tp );

        # Add default samples for which we have little or no metadata
        # (locations, in particular, are only recorded for a subset of
        # samples in the spreadsheets. We'll have to go back and fix
        # them later).
        if ( $self->auto_create_implied_samples() ) {
            foreach my $type ( ('genomic DNA','serum','plasma') ) {
                my $name = $patient->getAttribute('trial_id') . " $type" . ( defined $tp ? " $tp" : q{} );
                $self->find_or_create_sample( { $TNUM     => $name,
                                                $CELLTYPE => 'none',
                                                $MATERIAL => $type }, $visit );
            }
        }
    }
}

sub parse_bleed_date {

    my ( $self, $input ) = @_;

    my ( $d, $m, $y, $disamb )
        = ( $input =~ m!\A (\d{2})(\d{2})(\d{2}) ([abnc]+)? \z!ixms );
    return unless ( $d && $m && $y );
     
    my $date = sprintf("20%02d-%02d-%02d", $y, $m, $d);

    return wantarray ? ( $date, $disamb ) : $date;
}

sub import_rna_samples {

    my ( $self, $sheet ) = @_;

    my $iter = CIMR::SheetIterator->new( sheet => $sheet );

    my @expected = (
        $PNUM,
        $PNAME,
        $HNUM,
        $BLEEDDAT,
        $CELLTYPE,
        $TNUM,
        $CONC,
        $PURITY,
        $BOX,
        $LOCATION,
    );

    $self->check_iterator($iter, \@expected);

    RNA:
    while ( my $rowhash = $iter->next() ) {

        # Find the patient.
        my $id = $rowhash->{$PNUM};

        # Strip of any trailing "a" characters. These would typically
        # denote trial re-entry, but that's already being tracked by
        # the nominal timepoints.
        $id =~ s/a\z//ixms;
        next RNA unless $id && $rowhash->{$TNUM};

        my @patients = $self->root->findnodes(qq{./Patients/Patient[\@trial_id="$id"]});
        my $patient;
        if ( scalar @patients == 1 ) {
            $patient = $patients[0];
        }
        else {
            die("Error: Patient ID not found: $id\n");
        }

        # Determine the bleed date.
        my ( $date, $disamb ) = $self->parse_bleed_date( $rowhash->{$BLEEDDAT} )
            or croak("Unparseable date field: $rowhash->{$BLEEDDAT}\n");

        my @visits = $patient->findnodes(qq{./Visits/Visit[\@date="$date"]});
        my $visit;
        if ( scalar @visits == 1 ) {
            $visit = $visits[0];
        }
        else {
            die("Error: Visit for patient $id on $date not found.\n");
        }

        # Record the disambiguation A/B character where included in
        # the bleed date.
        my $notes = $visit->getAttribute('notes') || q{};
        if ( $disamb ) {
            unless ( $notes =~ /\bBleed $disamb\b/ ) {
                $notes .= " Bleed $disamb";
                $visit->setAttribute('notes', $notes);
            }
        }

        my $db_visit = $self->retrieve_visit( $date, $id );

        # Create a new Sample.
        $rowhash->{$MATERIAL} ||= 'RNA';
        my $sample = $self->find_or_create_sample( $rowhash, $visit );
    }
}

sub not_null {

    my ( $self, $value ) = @_;

    return (defined $value && $value ne q{});
}

package main;

use Getopt::Long;
use Pod::Usage;

sub parse_args {

    # Parse command-line options.
    my ( $conffile, $spreadsheet, $xsd, $no_auto_samples, $want_help );
    GetOptions(
        "c|config=s" => \$conffile,
        "d|schema=s" => \$xsd,
        "f|file=s"   => \$spreadsheet,
        "n|no-auto"  => \$no_auto_samples,
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

    return( $conffile, $spreadsheet, $xsd, $no_auto_samples );
}

# Parse command-line options.
my ( $conffile, $spreadsheet, $xsd, $no_auto_samples ) = parse_args();

# Connect to the database.
my $config = Config::YAML->new( config => $conffile );
my $connect_info = $config->{'Model::DB'}->{'connect_info'};
my $schema = ClinStudy::ORM->connect( @$connect_info );

my $excel = Spreadsheet::ParseExcel::Workbook->Parse($spreadsheet);

my %worksheet = map { $_->{Name} => $_ } @{ $excel->{Worksheet} };

my $bleedsheet = $worksheet{'bleed dates'}
    or die("Error: no bleed dates worksheet!\n");
my $rnasheet = $worksheet{'RNA'}
    or die("Error: no RNA worksheet!\n");

my $builder = MyBuilder->new(
    schema_file => $xsd,
    database    => $schema,
    auto_create_implied_samples => ! $no_auto_samples,
);

$builder->import_bleed_dates( $bleedsheet );
$builder->import_rna_samples( $rnasheet );

$builder->dump();

__END__

=head1 NAME

import_sample_data.pl

=head1 SYNOPSIS

 import_sample_data.pl -c <config file> -d <XML schema file> -f <sample spreadsheet>

=head1 DESCRIPTION

Script to convert the sample tracking Excel spreadsheet file into
ClinStudyML format for loading into the database. It is intended that
XML objects should only be created for objects differing from their
database counterparts (or not yet inserted into the
database). Currently this only really holds true for Samples; Patients
and Visits are created regardless.

=head1 AUTHOR

Tim F. Rayner, E<lt>tfrayner@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
