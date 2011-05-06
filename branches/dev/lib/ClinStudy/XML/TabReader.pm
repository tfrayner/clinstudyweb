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

package ClinStudy::XML::TabReader;

use ClinStudy::XML::Builder;
use Moose;
extends 'ClinStudy::XML::Builder';

use Text::CSV_XS;
use List::Util qw(first);

has 'tabfile'     => ( is       => 'ro',
                       isa      => 'Str',
                       required => 1 );

has 'drug_parent' => ( is       => 'ro',
                       isa      => 'Str',
                       required => 1,
                       default  => 'Visit' );

has '_used'       => ( is       => 'rw',
                       isa      => 'HashRef',
                       required => 1,
                       default  => sub{ {} } );

sub read {

    my ( $self ) = @_;

    my $drug_parent = $self->drug_parent();

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
    my ( $parsetree, $rootname ) = $self->_to_tree( \%parent_map );

    unless ( $rootname eq 'ClinStudyML' ) {
        
        # This is an internal script editor; somehow the %parent_map has become corrupted.
        die("Error: Root element is not ClinStudyML; shurely shome mishtake?");
    }

    my $csv = Text::CSV_XS->new({
        sep_char  => "\t",
        eol       => "\n",
    }) or die("Unable to initialise CSV parser.");

    my $tabfile = $self->tabfile();
    open (my $fh, '<', $tabfile)
        or die("Unable to open file $tabfile:$!\n");

    my ( $headstr, $header );
    until ( $headstr && $headstr !~ /^\s*#/ ) {
        $header = $csv->getline($fh);
        unless ( $header && ref $header eq 'ARRAY' ) {
            die("Unable to read file header line.\n");
        }
        $headstr = join('', @$header);
    }

    # Strip whitespace on either side of each column header.
    $header = [ map { s/ \A \s* (.*?) \s* \z /$1/ixms; $_ } @$header ];

    my %unused;
    LINE:
    while ( my $line = $csv->getline($fh) ) {
        
        my $str = join('', @$line);
        next LINE if $str =~ /^\s*#/;
        
        my %col;
        @col{@$header} = @$line;

        $self->recursive_cols_to_elements( \%col, $parsetree );

        # A mechanism to warn on unused columns.
        foreach my $un ( grep { ! $self->_column_used($_) } @$header ) {
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

    return;
}

sub recursive_cols_to_elements {

    my ( $self, $colhash, $tree, $parent, $level ) = @_;

    # Undefined or zero level indicates we're starting a new set of columns.
    # Deactivated because a file-level view is more useful than a row-level view.
#    unless ( $level ) {
#        $self->_reset_used_columns();
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
            if ( $col_class && $col_class eq $class ) {

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
            $self->recursive_cols_to_elements( $colhash, $tree->{ $class }, $elem, $level );
        }
    }

    return;
}

sub _reset_used_columns {

    my ( $self ) = @_;

    $self->_used({});

    return;
}

sub _column_used {

    my ( $self, $column ) = @_;

    return exists $self->_used()->{ $column };
}

sub _find_endpoint {

    # Find the first value in the passed hashref which doesn't also
    # correspond to a key.
    my ( $self, $hashref, $term, $level ) = @_;

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
    return $self->_find_endpoint( $hashref, $hashref->{$term}, $level );
}

sub _to_tree {

    # Function converts a hashref of child=>parent elements into a
    # nested tree structure.
    my ( $self, $hashref, $parent, $level ) = @_; 

    # Try to do this safely.
    unless ( $level++ < 100 ) {
	die("Error: deep recursion in hash tree conversion.");
    }

    $parent ||= $self->_find_endpoint( $hashref );

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
	$tree{ $key } = $self->_to_tree( $hashref, $key, $level );
    }

    return wantarray ? ( \%tree, $parent ) : \%tree;
}

1;

__END__

=head1 NAME

ClinStudy::XML::TabReader - Utility module for creating ClinStudyML documents.

=head1 SYNOPSIS

 use ClinStudy::XML::TabReader;
 my $builder = ClinStudy::XML::TabReader->new({
     tabfile => 'filename.txt',
 });
 my $root    = $builder->root();

 $builder->read();

 # Output the finished document.
 $builder->dump( \*STDOUT );

=head1 DESCRIPTION

A module initially intended to facilitate conversion of tab-delimited
data to ClinStudyML. See the C<ClinStudy::XML::Builder> superclass for
more information.

=head1 ATTRIBUTES

Note that XML Builder attributes are handled by the
C<ClinStudy::XML::Builder> superclass.

=head2 tabfile

The tab-delimited file to read. Only one file can be read per TabReader
object instantiation.

=head2 drug_parent

Optional. Drugs and TestResults can in principle be attached to either Visit or
Hospitalisation, and Drugs can further be attached to
PriorTreatment. Only one parent class can be supported per run of this
script. By default we attempt to attach everything to Visit, but this
attribute allows the user to redirect the attachment if necessary.

=head1 METHODS

=head2 read

Read the tab-delimited file and create the appropriate XML nodes in memory.

=head2 recursive_cols_to_elements

Core recursive method used to map column names onto the XML elements
generated by the Builder superclass. This method may be overridden in
subclasses for extension purposes.

=head1 SEE ALSO

L<ClinStudy::XML::Builder>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

