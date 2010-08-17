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
# Nascent script to start the data extraction/QC/normalisation pipeline.
#
# $Id$

use strict;
use warnings;

use File::Spec;
use Log::Log4perl qw(get_logger);

use CIMR::DataPipeline;

# Set our logging config file, and regenerate it from <DATA> if necessary.
my $log_config = File::Spec->catfile( $ENV{HOME}, '.cimr-data-pipeline.conf' );
unless ( -r $log_config ) {
    warn("Warning: Logging config file is being generated: $log_config\n");
    open( my $fh, '>', $log_config )
        or die("Error: Unable to open new logging config file $log_config: $!");
    while ( my $l = <DATA> ) {
        print $fh $l;
    }
}

# Set up our logger.
Log::Log4perl->init_and_watch( $log_config, 60 );
my $log = get_logger("CIMR::DataPipeline");

# Set up a signal handler for exceptions.
local %SIG;   # Not sure if this really has an effect.
$SIG{__DIE__} = sub { $log->fatal("Exiting: ", @_) };

# Instantiate the pipeline, and start it running.
$log->debug('Instantiating CIMR::DataPipeline object');
my $pipeline = CIMR::DataPipeline->new(
    config_file => $log_config,
);

$log->debug('Launching CIMR::DataPipeline object');
$pipeline->run();

__DATA__

# Core Log4perl configuration here.
log4perl.logger.CIMR.DataPipeline             = DEBUG, A1
#log4perl.appender.A1                          = Log::Dispatch::File
log4perl.appender.A1                          = Log::Dispatch::Screen
log4perl.appender.A1.filename                 = cimr-data-pipeline.log
log4perl.appender.A1.mode                     = append
log4perl.appender.A1.layout                   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.A1.layout.ConversionPattern = %d %p> %F{1}:%L %M - %m%n

# These first two should both point to the same location; one under Unix, the other under Wine/Windows.
cimr.datapipeline.watchfolder         = /PATH/TO/YOUR/DATA/WATCHFOLDER
cimr.datapipeline.watchfolder.windows = C:\\windows\profiles\PATH\TO\YOUR\DATA\WATCHFOLDER

# This is the DB_File database which keeps track of which files have been processed.
cimr.datapipeline.watchfolder.cache   = /WHERE/YOU/WANT/THE/CACHE/DATABASE/.cimr-data-pipeline-cache.db

# This command will be followed immediately by the name of the TIFF
# file to extract. N.B. I've not had any luck with filesystem paths
# containing spaces in the /ID option.
cimr.datapipeline.sys.extraction = /Applications/Darwine/Wine.bundle/Contents/bin/wine \
    /YOUR/HOME/DIRECTORY/.wine/drive_c/Program\ Files/Koada\ Technology/Koadarray/koadarray.exe \
    /IM

# These regular expressions determine what is processed as a TIFF or
# as a text data file. They must contain a single set of capture
# parentheses which return the array barcode. The regexp will be
# anchored to beginning and end of the filename being queried.
cimr.datapipeline.fileregexp.tiff = (?:US)? \d+ _ ( (?:\w+_)? \d{8} (?:_\w+)? ) _S \d+ (?:_\w+)? \.tiff?
cimr.datapipeline.fileregexp.txt  = (?:US)? \d+ _ ( (?:\w+_)? \d{8} (?:_\w+)? ) _S \d+ (?:_\w+)? \.txt

# Parameters used to query ClinWeb database
cimr.datapipeline.clinwebquery.uri          = http://localhost:3000
cimr.datapipeline.clinwebquery.idfield      = assay_barcode
cimr.datapipeline.clinwebquery.samplefield  = sample
cimr.datapipeline.clinwebquery.channelfield = channel
cimr.datapipeline.clinwebquery.datefield    = date

# Array annotation files.
cimr.datapipeline.adffile       = /PATH/TO/YOUR/ARRAYANNOTATION/FILES/Human25kOligoADF.txt
cimr.datapipeline.spottypesfile = /PATH/TO/YOUR/ARRAYANNOTATION/FILES/Human25kOligoSpotTypes.txt
    
