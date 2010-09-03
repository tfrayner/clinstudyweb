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
# Factory object supporting the creation of limma targets files from
# arbitrary lists of array data files.

use strict;
use warnings;

package CIMR::TargetGenerator;

use Moose;
use Carp;
use File::Temp qw(tempfile);
use List::Util qw(first);

has 'queryobj' => (
    is       => 'rw',
    isa      => 'CIMR::QueryObj',
    required => 1,
);

# FIXME consider removing the default - it may confuse things later...
has 'file_regexp' => (
    is       => 'rw',
    isa      => 'RegexpRef',
    required => 1,
    default  => sub { qr/\A (?:US)? \d+ _ (\d+) _ \w+ \.txt \z/xms },
);

has 'sample_field' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub { my ( $self, $field ) = @_; $self->_check_is_query_field( $field ) },
);

has 'channel_field' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub { my ( $self, $field ) = @_; $self->_check_is_query_field( $field ) },
);

has 'date_field' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub { my ( $self, $field ) = @_; $self->_check_is_query_field( $field ) },
);

has 'output_file' => (
    is       => 'rw',
    isa      => 'Str',
    required => 0,
);

has 'unused' => (
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    required   => 0,
    auto_deref => 1,
    clearer    => 'clear_unused',
);

# Check that sample_field and channel_field both correspond to one of
# queryobj->queryterms. All other queryterms will be dumped into the
# output targets file.

sub _check_is_query_field {

    my ( $self, $field ) = @_;

    my $qobj    = $self->queryobj();
    my @allowed = $qobj->queryterms();

    unless ( first { $_ eq $field } @allowed ) {
        confess(qq{Error: Field "$field" not in the query object queryterms list.\n});
    }

    return;
}

sub create {

    my ( $self, $datafiles ) = @_;

    unless( UNIVERSAL::isa( $datafiles, 'ARRAY' ) ) {
        confess("Error: Argument to create() must be an arrayref of data file names.\n");
    }

    # Reset our list of unused filenames.
    $self->clear_unused();

    my ( $filename, $fh ) = $self->_get_outputs();

    # Figure out what we can about the datafiles we have.
    my $dye_swaps = $self->_retrieve_annotation( $datafiles );
    $self->_filter_unpaired_hybs( $dye_swaps );

    # Count the number of complete dye swaps.
    my $num_swaps = scalar grep { defined $_ } values %{ $dye_swaps };

    # Generate the output.
    $self->_print_targets_file( $dye_swaps, $fh );
    seek( $fh, 0, 0 ) or croak("Error: Problem rewinding targets file: $!\n");

    return ( $filename, $fh, $num_swaps );
}

sub _get_outputs {

    my ( $self ) = @_;

    my ( $filename, $fh );
    if ( $filename = $self->output_file() ) {
        open( $fh, '>', $filename )
            or croak(qq{Error: Unable to open output file "$filename": $!\n});
    }
    else {
        ( $fh, $filename ) = tempfile();
        $self->output_file( $filename );
    }

    return( $filename, $fh );
}

sub _retrieve_annotation {

    my ( $self, $datafiles ) = @_;

    my $qobj   = $self->queryobj();

    # We filter out channel_field, sample_field from @query since
    # they're covered elsewhere.
    my $ch_field = $self->channel_field();
    my $sa_field = $self->sample_field();
    my @query  = grep { $_ ne $ch_field } $qobj->queryterms();

    my %dye_swaps;
    my @unused = $self->unused();

    foreach my $datafile ( @{ $datafiles } ) {
        my ( $code ) = ( $datafile =~ $self->file_regexp() );
        unless ( defined $code ) {
            croak(qq{Error: Cannot parse bar code from file name "$datafile".\n})
        }
        
        my ( $sample, $channel, $date ) = $qobj->query(
            $code,
            $self->sample_field(),
            $self->channel_field(),
            $self->date_field(),
        );

        # The strings NA and na are special-cased here to represent undef.
        if ( ( scalar grep { defined $_ && lc($_) ne 'na' }
                   ( $sample, $channel, $date ) ) == 3 ) {

            # We use a combination of sample name and hyb date to
            # create unique tags. If a sample is hybridized more than
            # once on a given date that's a problem; also a problem if
            # the dye swaps for a given sample were done on different
            # dates.
            my $hybrid = "$sample:$date";

            # I think this would be a fatal error, at least for our
            # in-house data. Subsequent steps would also be broken by
            # this.
            if ( exists $dye_swaps{ $hybrid } && exists $dye_swaps{ $hybrid }{ $channel } ) {
                croak(qq{Error: Multiple arrays for date "$date" have sample "$sample" in channel "$channel".\n});
            }

            my @results = $qobj->query( $code, @query );
            my %annot;
            @annot{ @query } = @results;
            $dye_swaps{ $hybrid }{ $channel } = { 'barcode'    => $code,
                                                  'file'       => $datafile,
                                                  'annotation' => \%annot, };
        }
        else {

            # Record the failure and return it (as an attribute of
            # $self) so we can manage arrays in the caller.
            push @unused, $datafile;
        }
    }

    # Record this so that the caller can access it if necessary.
    $self->unused( \@unused );

    return( \%dye_swaps );
}

sub _filter_unpaired_hybs {

    my ( $self, $dye_swaps ) = @_;

    my @unused = $self->unused();

    # Filter out singletons.
    foreach my $hybrid ( keys %{ $dye_swaps } ) {
        my $nchan = scalar grep { defined $_ } values %{ $dye_swaps->{ $hybrid } };
        if ( $nchan < 1 ) {
            delete $dye_swaps->{ $hybrid };
        }
        elsif ( $nchan == 1 ) {

            # May want to revisit this if we ever move into e.g. Affy data.
            my $chandata = ( values %{ $dye_swaps->{ $hybrid } } )[0];
            push @unused, $chandata->{'file'};
            delete $dye_swaps->{ $hybrid };
        }
        elsif ( $nchan > 2 ) {

            # Again this would be an error in our data. Downstream R
            # code assumes two channels.
            croak(qq{Error: Hybridisation "$hybrid" is linked to more than two channels.\n});
        }
    }

    # Record this so that the caller can access it if necessary.
    $self->unused( \@unused );

    return;
}

sub _print_targets_file {

    my ( $self, $dye_swaps, $fh ) = @_;

    # Print the output; first the header.

    # N.B. We inspect an entry in $dye_swaps to get at the annotation
    # keys, rather than assuming that $self->queryobj->queryterms
    # covers it.
    my @annot_headings;
    ANNOT:
    foreach my $sample ( keys %{ $dye_swaps } ) {
        foreach my $channel ( keys %{ $dye_swaps->{ $sample } } ) {
            @annot_headings = sort keys %{ $dye_swaps->{ $sample }{ $channel }{ 'annotation' } };
            last ANNOT;
        }
    }
    print $fh ( join("\t", qw(FileName Slidename Hybridization Cy3 Cy5), @annot_headings ), "\n");

    # Print out the body.
    while ( my ( $hybrid, $hyb ) = each %{ $dye_swaps } ) {
        while ( my ( $channel, $chandata ) = each %{ $hyb } ) {

            # Note that using 'Ref' here needs to be synchronised with its
            # use in subsequent R code.
            my $cy3 = ( $channel =~ /\A (?:cy)? 3 \z/ixms ? $hybrid : 'Ref' );
            my $cy5 = ( $channel =~ /\A (?:cy)? 5 \z/ixms ? $hybrid : 'Ref' );
            unless ( $cy3 ne $cy5 ) {
                croak(qq{Error: Hybridisation "$hybrid" channel information doesn't make sense: "$channel"\n});
            }
            my @annotation = map { defined $_ ? $_ : q{} }
                             map { $chandata->{'annotation'}{ $_ } }
                             sort keys %{ $chandata->{'annotation'} };

            # N.B. the R code assumes barcode in the Slidename column.
            print $fh( join("\t",
                            $chandata->{'file'},
                            $chandata->{'barcode'},
                            $hybrid,
                            $cy3,
                            $cy5,
                            @annotation,
                            ), "\n" );
        }
    }
}

1;

=head1 NAME

CIMR::TargetGenerator - Create limma Targets files from CIMR::QueryObj instances.

=head1 SYNOPSIS

 use CIMR::TargetGenerator;
 my $qobj = ClinStudy::WebQuery->new(
     uri        => 'http://localhost:3000',
     username   => 'my_username',
     password   => 'my_password',
     id_field   => 'assay_barcode',
 );
 my $tgen = CIMR::TargetGenerator->new(
     queryobj      => $qobj,
     file_regexp   => qr/ \w* (\d{8}) \w* \.txt \z/xms,
     sample_field  => 'sample',
     channel_field => 'channel',
     date_field    => 'date',
 );
 my ( $targets_file, $targets_fh, $num_swaps ) = $tgen->create( \@filenames );

=head1 DESCRIPTION

Module used to simplify the creation of Targets files for dye-swap
microarray data.

Given a suitable CIMR::QueryObj instance, a list of data files, and a
regular expression which captures the part of the data file name used
as an identifier by the QueryObj, this class can generate a Targets
file suitable for use with the Bioconductor limma package.

Note that there are generally better ways to do this nowadays, most
notably the csWebAffyBatch and csWebRGList functions available as part
of the ClinStudyWeb R package. This subsystem is really only kept
around to help drive the CIMR::DataPipeline class.

=head1 ATTRIBUTES

=head2 queryobj

The CIMR::QueryObj to use as an input data store.

=head2 file_regexp

A regular expression used to convert filenames into identifiers
suitable for use with the C<queryobj> object. The expression should
contain one set of capture parentheses which extracts the identifier
string from the filename. The default is:

 qr/\A (?:US)? \d+ _ (\d+) _ \w+ \.txt \z/xms

=head2 sample_field

The field stored in the C<queryobj> object corresponding to a sample identifier.

=head2 channel_field

The field stored in the C<queryobj> object corresponding to a channel
designation (e.g. Cy3, Cy5).

=head2 date_field

The field stored in the C<queryobj> object corresponding to the hybridisation date.

=head2 output_file

The name of the output Targets file. If this is not specified a
File::Temp object will be created. The name of the targets file is
returned, alongside its filehandle, by the C<create> method (see
below).

=head2 unused

Returns a list of unused filenames. This can be used to track whether
or not filenames are found in the C<queryobj> data store. Use
C<clear_unused> to clear this list.

=head1 METHODS

=head2 create

Given a list of filenames, apply the C<file_regexp> expression to
extract identifier strings from these filenames, and then use those
identifiers to query the C<queryobj> object, retrieving
C<sample_field>, C<channel_field> and C<date_field>
information. Constructs a Targets file (C<output_file>) and returns
the name of that file, its filehandle, and the total number of dye
swaps detected.

=head1 SEE ALSO

ClinStudyWeb R package,
L<CIMR::DataPipeline>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

