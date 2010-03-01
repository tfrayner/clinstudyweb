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

has '_used' => ( is => 'rw',
                 isa => 'HashRef',
                 required => 1,
                 default  => sub{ {} } );

sub process_columns {

    my ( $self, $colhash, $tree, $parent, $level ) = @_;

    # Undefined or zero level indicates we're starting a new set of columns.
    # Deactivated because a file-level view is more useful than a row-level view.
#    unless ( $level ) {
#        $self->reset_used_columns();
#    }
    $parent ||= $self->root;
    
    # Try to do this safely.
    unless ( $level++ < 100 ) {
	die("Error: deep recursion in column processing.");
    }

    foreach my $class ( keys %$tree ) {

        # Aggregate class attributes into a single hash, then find or
        # create it.
        my %attrhash;
        while ( my ( $key, $value ) = each %$colhash ) {
	    my ( $col_class, $attrname ) = split /\|/, $key;
            if ( $col_class eq $class ) {

                # Record that we've at least considered this column.
                $self->_used()->{ $key }++;

                # Add the value to the element attribute hash.
                if ( defined $value && $value ne q{} ) {
                    $attrhash{ $attrname } = $value;
                }
            }
	}

        if ( scalar grep { defined $_ } values %attrhash ) {
            my $elem = $self->update_or_create_element( $class, \%attrhash, $parent );
        
            # Recursion time.
            $self->process_columns( $colhash, $tree->{ $class }, $elem, $level );
        }
    }

    return;
}

sub reset_used_columns {

    my ( $self ) = @_;

    $self->_used({});

    return;
}

sub column_used {

    my ( $self, $column ) = @_;

    return exists $self->_used()->{ $column };
}

#################################################################################
package main;

use Getopt::Long;
use Pod::Usage;
use Text::CSV_XS;
use XML::LibXML;
use List::Util qw(first);

########
# SUBS #
########

sub parse_args {

    my ( $tabfile, $xsd, $drug_parent, $xmldoc, $relaxed, $want_help );

    GetOptions(
        "f|file=s"   => \$tabfile,
        "r|relaxed"  => \$relaxed,
        "d|schema=s" => \$xsd,
        "x|xml=s"    => \$xmldoc,
        "p|drug-parent=s" => \$drug_parent,
        "h|help"     => \$want_help,
    );

    if ($want_help) {
        pod2usage(
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 1,
        );
    }

    unless ( $tabfile && $xsd ) {
        pod2usage(
            -message => qq{Please see "$0 -h" for further help notes.},
            -exitval => 255,
            -output  => \*STDERR,
            -verbose => 0,
        );
    }

    $drug_parent ||= 'Visit';

    my $xml;
    if ( $xmldoc ) {
        my $parser = XML::LibXML->new();
        $xml       = $parser->parse_file($xmldoc);
    }

    return( $tabfile, $xsd, $relaxed, $drug_parent, $xml );
}

sub find_endpoint {

    # Find the first value in the passed hashref which doesn't also
    # correspond to a key.
    my ( $hashref, $term, $level ) = @_;

    # Try to do this safely.
    unless ( $level++ < 100 ) {
	die("Error: deep recursion in hash endpoint detection.");
    }

    $term ||= (keys %$hashref)[0];

    # Ideally we would somehow detect cases where there are multiple
    # possible endpoints. We can't support more than one top-level
    # element class because there's no way to know which element we'd
    # end up with. Ultimately such cases would be reflected in some
    # columns not being exported.
    return $term unless exists $hashref->{$term};

    # Recurse into the hashref structure.
    return find_endpoint( $hashref, $hashref->{$term}, $level );
}

sub to_tree {

    # Function converts a hashref of child=>parent elements into a
    # nested tree structure.
    my ( $hashref, $parent, $level ) = @_; 

    # Try to do this safely.
    unless ( $level++ < 100 ) {
	die("Error: deep recursion in hash tree conversion.");
    }

    $parent ||= find_endpoint( $hashref );

    # We have to go around the houses a bit here because of the
    # asinine behaviour of perls each() function.
    my @next;
    while ( my ( $key, $value ) = each %$hashref ) {
	if ( $value eq $parent ) {
	    push @next, $key;
	}
    }
    my %tree;
    foreach my $key ( @next ) {
	$tree{ $key } = to_tree( $hashref, $key, $level );
    }

    return wantarray ? ( \%tree, $parent ) : \%tree;
}

########
# MAIN #
########

my ( $tabfile, $xsd, $relaxed, $drug_parent, $xml ) = parse_args();

unless ( first { $drug_parent eq $_ } qw( Visit Hospitalisation PriorTreatment ) ) {
    die("Error: Unsuitable Drug/TestResult parent class specified ($drug_parent).\n");
}

# The %parent_map hash controls the eventual structure of the output
# XML. Here we convert it into a nested hashref of hashrefs. Note that
# if the schema changes then this may also need to change. FIXME
# ideally we'd derive this directly from the XML schema.
my %parent_map = (
    'AdverseEvent'      => 'Patient',
    'Assay'             => 'AssayBatch',
    'AssayBatch'        => 'ClinStudyML',
    'AssayQcValue'      => 'Assay',
    'Channel'           => 'Assay',
    'ClinicalFeature'   => 'Patient',
    'Comorbidity'       => 'Patient',
    'Diagnosis'         => 'Patient',
    'DiseaseEvent'      => 'Patient',
    'Drug'              => $drug_parent,
    'EmergentGroup'     => 'Visit',
    'GraftFailure'      => 'Transplant',
    'Hospitalisation'   => 'Patient',
    'Patient'           => 'ClinStudyML',
    'PriorGroup'        => 'Patient',
    'PriorObservation'  => 'Patient',
    'PriorTreatment'    => 'Patient',
    'RiskFactor'        => 'Patient',
    'Sample'            => 'Visit',
    'Study'             => 'Patient',
    'SystemInvolvement' => 'Patient',
    'TestResult'        => $drug_parent,  # FIXME if this is PriorTreatment we may be screwed.
    'Transplant'        => 'Hospitalisation',
    'Visit'             => 'Patient',
);
my ( $parsetree, $rootname ) = to_tree( \%parent_map );

unless ( $rootname eq 'ClinStudyML' ) {

    # This is an internal script editor; somehow the %parent_map has become corrupted.
    die("Error: Root element is not ClinStudyML; shurely shome mishtake?");
}

my %build_opts = (
    schema_file  => $xsd,
    is_strict    => ! $relaxed,
);
$build_opts{root} = $xml->getDocumentElement() if ( $xml );
my $builder = MyBuilder->new(%build_opts);

my $csv = Text::CSV_XS->new({
    sep_char  => "\t",
    eol       => "\n",
}) or die("Unable to initialise CSV parser.");

open (my $fh, '<', $tabfile)
    or die("Unable to open file $tabfile:$!\n");

my $header = $csv->getline($fh);
my %unused;
while ( my $line = $csv->getline($fh) ) {

    my %col;
    @col{@$header} = @$line;

    $builder->process_columns( \%col, $parsetree );

    # A mechanism to warn on unused columns.
    foreach my $un ( grep { ! $builder->column_used($_) } @$header ) {
        $unused{ $un }++;
    }
}

# Check that parsing completed successfully.
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

# Warn on any unused columns.
if ( scalar grep { defined $_ } values %unused ) {
    warn("Warning: Unused columns: ", join(", ", keys %unused), "\n");
}

$builder->dump();

__END__

=head1 NAME

tab2clinstudy.pl

=head1 SYNOPSIS

 tab2clinstudy.pl -f <tab-delimited file> -d <XML Schema file>

=head1 DESCRIPTION

This script generates ClinStudyML from an input tab-delimited
file. The file headings must be of the form "Element|attribute", for
example "Patient|entry_date".

=head2 OPTIONS

=over 2

=item -f

The tab-delimited file to convert into XML.

=item -d

The XML Schema document against which to validate.

=item -r

Flag indicating that the script should run in relaxed mode, i.e. the
generated XML does not need to be valid (although it must still be
well-formed).

=item -p

Drugs and TestResults can in principle be attached to either Visit or
Hospitalisation, and Drugs can further be attached to
PriorTreatment. Only one parent class can be supported per run of this
script. By default we attempt to attach everything to Visit, but this
option allows the user to redirect the attachment if necessary.

=item -h

Generates this help text.

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
