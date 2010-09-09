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

package CIMR::DataPipeline;

use ClinStudy::WebQuery;
use CIMR::TargetGenerator;

use Log::Log4perl qw(get_logger);
use POSIX qw(:fcntl_h);
use DB_File;
use File::Spec;
use Carp;
use Cwd;

use Moose;

has 'logger'  => (
    is       => 'ro',
    isa      => 'Log::Log4perl::Logger',
    required => 1,
    default  => sub { get_logger("CIMR::DataPipeline") },
);

has 'interval' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
    default  => 60,
);

has 'config_file'  => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has '_config'  => (
    is       => 'rw',
    isa      => 'Log::Log4perl::Config::BaseConfigurator',
    required => 0,
);

has '_cache'   => (
    is       => 'rw',
    isa      => 'DB_File',
    required => 0,
);

has '_rscript'   => (
    is       => 'rw',
    isa      => 'Str',
    required => 0,
);

sub BUILD {

    my ( $self, $params ) = @_;

    # Read our config file.
    if ( my $file = $self->config_file ) {
        
        my $conf = Log::Log4perl::Config::PropertyConfigurator->new();
        $conf->file( $file );
        $conf->parse();

        $self->_config( $conf );
    }

    unless ( $self->_config ) {
        confess("Error: DataPipeline instantiation requires config_file parameter.")
    }

    # Set _rscript; allow the config file to override, but have a backup ready.
    my $rscript;
    unless ( $rscript = $self->_config->value('cimr.datapipeline.rscript') ) {

        # If not set, assume the R script is in the same directory as
        # this module.
        my @path = File::Spec->splitpath( File::Spec->rel2abs(__FILE__) );
        $rscript = File::Spec->catpath( @path[ 0, 1 ], 'dataPipeline.R' );
    }
    $self->_rscript( $rscript );

    # Attach our cache hash to its DB_File container. FIXME we'll want
    # to think about how to lock this cache file at some point - see
    # the DB_File docs for fd gotchas.
    if ( my $cachefile = $self->_config->value('cimr.datapipeline.watchfolder.cache') ) {

        # Create a new DB, or attach to a pre-existing file.
        my $flags = O_RDWR|O_EXCL;
        $flags |= O_CREAT unless -f $cachefile;
        my $obj = tie my %cache, 'DB_File', $cachefile, $flags, oct(666), $DB_BTREE
            or confess("Error: unable to connect to cache file: $!");

        $self->logger->debug(
            sub {sprintf('Cache previously contained %d files', scalar keys %cache)}
        );

        # Store the cache where we can get at it later.
        $self->_cache( $obj );
    }
    else {
        croak("Error: Config file must contain a cimr.datapipeline.watchfolder.cache value.");
    }
}

sub run {

    my ( $self ) = @_;

    $self->logger->debug("Pipeline now running.");

    # We watch our config file for changes. Note that Log::Log4perl is
    # likely doing this as well behind the scenes, depending on how it
    # was set up in our caller.
    my $config_watcher = Log::Log4perl::Config::Watch->new(
        file            => $self->config_file(),
        check_interval  => $self->interval(),
    );

    # This is a factory object used to create targets files for limma.
    my $tgen = $self->_get_target_generator();
    
    while (1) {

        # Run a quick check to reload the config if necessary.
        if ( $config_watcher->change_detected() ) {
            $self->logger->info("Detected config file change; reparsing");
            $self->_config->file( $self->config_file() );
            $self->_config->parse();
        }

        $self->logger->debug(sub { "Polling the watch directory: "
                                 . $self->_config->value('cimr.datapipeline.watchfolder') } );

        # Get a list of all new files.
        my $files = $self->_find_new_files();

        # The config file determines what is a TIFF and what is not.
        my $tiff_re = $self->_config->value('cimr.datapipeline.fileregexp.tiff');
        $tiff_re    = qr/\A $tiff_re \z/ixms;
        my @tiffs   = grep { $_ =~ $tiff_re } @$files;
        my $tif_num = scalar @tiffs;
        $self->logger->info("Found $tif_num new TIFF data files");

        # Extract the data.
        foreach my $file ( @tiffs ) {
            $self->_extract_data( $file );
        }

        # We manage this regexp fairly carefully, so that we can be
        # sure all passing TXT file names can be parsed into
        # barcodes. The regexp is used here and when creating the
        # TargetGenerator object ($tgen).
        my $text_re   = $self->_config->value('cimr.datapipeline.fileregexp.txt');
        $text_re      = qr/\A $text_re \z/ixms;
        my @extracted = grep { $_ =~ $text_re } @$files;
        my $ext_num = scalar @extracted;
        $self->logger->info("Found $ext_num new extracted data files");
        my ( $targets_file, $targets_fh, $num_swaps ) = $tgen->create( \@extracted );

        # Delete unused filenames from the cache; we'll look at them
        # again next time around.
        my @unused = $tgen->unused();
        my $cache  = $self->_cache();
        foreach my $file ( @unused ) {
            $self->logger->info("Targets generation skipped file: $file");
            my $status = $cache->del( $file );
            $self->logger->debug(
                sub { sprintf(qq{Deleted unused file "%s" from cache file with status %s}, $file, $status) } );
        }

        # Save changes to the database.
        $cache->sync() != -1
            or confess("Error: problem synchronising cache DB: $!");

        # Finally, call the R code here.
        if ( $num_swaps ) {
            $self->_call_r_code( $targets_file );
        }
        
        sleep( $self->interval() );
    }

    $self->logger->debug("Pipeline exiting.");
    return;
}

sub _call_r_code {

    my ( $self, $targets_file ) = @_;

    $self->logger->info("Running R analysis on targets file: $targets_file");

    my $cwd = getcwd();
    chdir( $self->_config->value('cimr.datapipeline.watchfolder') )
        or croak("Error changing directory: $!");

    # N.B. assumes that Rscript is on the user's PATH.
    # N.B. now also assumes an x86 64bit architecture. FIXME.
    my $syscall = sprintf(
        "Rscript --arch=x86_64 %s %s %s %s",
        $self->_rscript(),
        $targets_file,
        $self->_config->value('cimr.datapipeline.spottypesfile'),
        $self->_config->value('cimr.datapipeline.adffile'),
    );
    system( $syscall ) == 0
        or croak("ERROR: Problem running R analysis: $?");
    $self->logger->info("Completed R analysis");

    chdir( $cwd )
        or croak("Error changing directory: $!");

    return;
}

sub _find_new_files {

    my ( $self ) = @_;

    $self->logger->debug("Looking for new files.");

    my $cache    = $self->_cache();
    my $watchdir = $self->_config->value('cimr.datapipeline.watchfolder');

    opendir( my $dfh, $watchdir )
        or croak(qq{Error: Unable to read watch folder "$watchdir": $!});

    my @files = grep { $_ !~ /^\./ && -f File::Spec->catfile($watchdir, $_) } readdir($dfh);

    closedir $dfh
        or confess(qq{Error: Unable to close watch directory "$watchdir": $!});

    # Check each found file against the database.
    my ( @new );
    foreach my $file ( @files ) {
        my $is_seen;
        $cache->get($file, $is_seen) != -1
            or confess("Error: problem reading file keys from cache DB: $!");
        unless ( $is_seen ) {
            $cache->put($file, 1) != -1
                or confess("Error: problem writing file keys to cache DB: $!");
            push @new, $file;
        }
    }
    
    # We want to clean out old files from the database as well.
    my %current = map { $_ => 1 } @files;
    my ( $key, $value );
    for ( my $status = $cache->seq( $key, $value, R_FIRST );
          $status == 0;
          $status = $cache->seq( $key, $value, R_NEXT ) ) {
        unless ( $current{ $key } ) {
            $status = $cache->del( $key );
            $self->logger->debug(
                qq{Deleted old file "$key" from cache file with status $status } );
        }
    }

    # Save changes to the database.
    $cache->sync() != -1
        or confess("Error: problem synchronising cache DB: $!");

    $self->logger->debug(sub { sprintf("Returning listing of %d new files", scalar @new ) } );

    return \@new;
}

sub _extract_data {

    my ( $self, $file ) = @_;

    $self->logger->info(qq{Extracting data from TIFF file "$file"});

    # This runs whatever external command we've set as the data
    # extraction tool. NOTE that currently it's all geared towards
    # running this tool under Wine and so the paths are all
    # Win32. Obviously this is incredibly ugly, but it's largely
    # dependent on the Koadarray command-line API.

    require File::Spec::Win32;
    my $path = File::Spec::Win32->catfile(
        $self->_config->value('cimr.datapipeline.watchfolder.windows'),
        $file,
    );
    $path = "'$path'";
    my $syscall = join(' ',
                       $self->_config->value('cimr.datapipeline.sys.extraction'),
                       $path,
                       '> /dev/null 2>&1');
    $self->logger->debug(qq{Using command:\n    $syscall});
    system( $syscall ) == 0
        or croak("Error executing data extraction application: $?");

    return;
}

sub _get_target_generator {

    my ( $self ) = @_;

    # Most of this information will comes from $self->_config().
    my $qobj = ClinStudy::WebQuery->new(
        'uri'        => $self->_config->value('cimr.datapipeline.clinwebquery.uri'),
        'username'   => $self->_config->value('cimr.datapipeline.clinwebquery.username'),
        'password'   => $self->_config->value('cimr.datapipeline.clinwebquery.password'),
        'id_field'   => $self->_config->value('cimr.datapipeline.clinwebquery.idfield'),
    );

    my $regexp = $self->_config->value('cimr.datapipeline.fileregexp.txt');
    $regexp    = qr/\A $regexp \z/ixms;
    my $tgen = CIMR::TargetGenerator->new(
        queryobj      => $qobj,
        file_regexp   => $regexp,
        sample_field  => $self->_config->value('cimr.datapipeline.clinwebquery.samplefield'),
        channel_field => $self->_config->value('cimr.datapipeline.clinwebquery.channelfield'),
        date_field    => $self->_config->value('cimr.datapipeline.clinwebquery.datefield'),
    );

    return $tgen;
}

no Moose;

1;

=head1 NAME

CIMR::DataPipeline - Local data preprocessing pipeline.

=head1 SYNOPSIS

 use CIMR::DataPipeline;
 my $pipeline = CIMR::DataPipeline->new(
    config_file => $filename,
 );
 $pipeline->run();

=head1 DESCRIPTION

This is a data preprocessing and QC pipeline class used in our local
installation. When run it checks a specified watch directory and
processes any new files, writing a log either to screen or to a log
file. Currently this class is used primarily to process GenePix-style
extracted microarray data files, filtering out poor hybridizations and
dubious array probes to give as clean as possible an output. The
pipeline uses the accompanying R script, dataPipeline.R, in
conjunction with the Bioconductor limma package to generate a series
of *.RData files containing MAList objects for individual dye-swap
pairs of data files, following print-tip loess normalisation.

Note that there is still code in this class which was used to extract
the original TIFF files, generating the GenePix-style data files; this
code should still work, but since it is no longer in use it is not
documented in this POD.

=head1 ATTRIBUTES

=head2 logger

A Log::Log4perl::Logger object; if none is supplied then the logger
designated as "log4perl.logger.CIMR.DataPipeline" from the config file
is used (see below).

=head2 interval

The time in seconds between checks on the watch directory.

=head2 config_file

The name or full path of the configuration file.

=head1 METHODS

=head2 run

Start the pipeline.

=head1 CONFIG FILE OPTIONS

=over 2

=item log4perl.logger.CIMR.DataPipeline

The main logger object used by this class. Note that further log4perl
config options will likely be needed to fully specify the logging
behaviour. For example:

 log4perl.logger.CIMR.DataPipeline             = DEBUG, A1
 log4perl.appender.A1                          = Log::Dispatch::Screen
 log4perl.appender.A1.filename                 = cimr-data-pipeline.log
 log4perl.appender.A1.mode                     = append
 log4perl.appender.A1.layout                   = Log::Log4perl::Layout::PatternLayout
 log4perl.appender.A1.layout.ConversionPattern = %d %p> %F{1}:%L %M - %m%n

=item cimr.datapipeline.watchfolder

The full path to the data watch directory.

=item cimr.datapipeline.watchfolder.cache

This is the DB_File database which keeps track of which files have
been processed.

=item cimr.datapipeline.fileregexp.tiff

=item cimr.datapipeline.fileregexp.txt

These regular expressions determine what is processed as a TIFF or as
a text data file. They must contain a single set of capture
parentheses which return the array barcode. The regexp will be
anchored to beginning and end of the filename being queried.

=item cimr.datapipeline.clinwebquery.uri

=item cimr.datapipeline.clinwebquery.idfield      = assay_barcode

=item cimr.datapipeline.clinwebquery.samplefield  = sample

=item cimr.datapipeline.clinwebquery.channelfield = channel

=item cimr.datapipeline.clinwebquery.datefield    = date

Parameters used to query ClinWeb database. The query is performed via
the REST API, using the URI specified. The various field designations
are unlikely to need changing from the values shown.

=item cimr.datapipeline.adffile

=item cimr.datapipeline.spottypesfile

Full paths to your array annotation files. These are ADF files and Spot
type files used to provide probe identifier and control type
information to the dataPipeline.R script.

=back

=head1 SEE ALSO

L<CIMR::TargetGenerator>,
L<ClinStudy::WebQuery>,
Log::Log4perl

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

