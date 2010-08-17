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

package ClinStudy::WebQuery;

use Moose;
use Carp;
use List::Util qw(first);
use LWP::UserAgent;
use XML::LibXML;

BEGIN { extends 'CIMR::QueryObj' };

has 'uri' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'username' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'password' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'queryterms' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    auto_deref => 1,
    default  => sub {[qw(channel sample cd disease patient_no cohort time_point date)]},
);

sub query {

    my ( $self, $id, @terms ) = @_;

    my $uri = $self->uri();

    my @known = $self->queryterms();
    foreach my $term ( @terms ) {
        unless ( first { $term eq $_ } @known ) {
            croak("Error: unrecognised query term $term.");
        }
    }

    # Strip trailing /, add the path to the REST API for id_field (typically 'assay_file').
    $uri =~ s/\/+$//;
    $uri .= sprintf("/rest/%s/%s", $self->id_field(), $id);
    my $ua = LWP::UserAgent->new();

    # Add our login details and content type.
    $ua->default_header( 'X-Username' => $self->username() );
    $ua->default_header( 'X-Password' => $self->password() );
    $ua->default_header( 'Content-Type' => 'text/xml' );

    # Get the response.
    my $res = $ua->get($uri);

    # Error-check the response, give feedback on failure.
    unless ( $res->is_success ) {
        warn(sprintf("Warning: ClinWebQuery returned error %s for %s %s\n",
                     $res->status_line, $self->id_field, $id));
        return;
    }

    # Parse the returned data.
    my $doc = XML::LibXML->load_xml(string => $res->content);
    use Data::Dumper;
    my $dataset = $doc->find('/opt/data');
    if ( $dataset->size() != 1 ) {
        croak("Error: ClinStudyWeb REST response must contain a single data entry");
    }
    my $data = $dataset->get_node(0);

    my %cache;

    my @channels = $data->findnodes('./channels');
    if ( @channels > 1 ) {
        croak('Error: Database contains assays with multiple channels.'
                  . ' This is not supported by the ClinWebQuery module at this time.')
    }
    elsif ( @channels == 1 ) {
        my $ch = $channels[0];
        $cache{'channel'} = $ch->getAttribute('label');
        my @samples = $ch->findnodes('./sample');
        if ( @samples == 1 ) {
            my $sa = $samples[0];
            $cache{'sample'}     = $sa->getAttribute('sample_name');
            $cache{'cd'}         = $sa->getAttribute('cell_type');
            $cache{'disease'}    = $sa->getAttribute('diagnosis');
            $cache{'patient_no'} = $sa->getAttribute('patient_number');
            $cache{'cohort'}     = $sa->getAttribute('cohort');
            $cache{'time_point'} = $sa->getAttribute('time_point');
        }
        else {
            warn(sprintf("Warning: No sample found for %s %s",
                         $self->id_field, $id));
            return;
        }
    }
    else {
        warn(sprintf("Warning: No channels found for %s %s",
                     $self->id_field, $id));
        return;
    }
    $cache{'date'} = $data->getAttribute('batch_date');
    
    return map { $cache{$_} } @terms;
}

1;
