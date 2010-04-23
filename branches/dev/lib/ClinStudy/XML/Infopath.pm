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

package ClinStudy::XML::Infopath;

use 5.008;

use strict; 
use warnings;

use Carp;

use Data::Dumper;

our $VERSION = '0.01';

use Moose;
use XML::LibXML;
use XML::LibXSLT;

use Date::Manip qw(ParseDate ParseDateDelta UnixDate Delta_Format Date_Init DateCalc);

# UK format DD/MM/YYYY is assumed.
Date_Init("DateFormat=non-US");

has 'stylesheet' => ( is       => 'ro',
                      isa      => 'Str',
                      required => 1, );

has '_xslt'      => ( is       => 'rw',
                      isa      => 'XML::LibXSLT::StylesheetWrapper', );

my $IS_NA_REGEXP = qr!\A n\/?[ad] \z!ixms;

sub BUILD {

    my ( $self, $params ) = @_;

    my $xslt       = XML::LibXSLT->new();
    my $parser     = XML::LibXML->new();
    my $style_doc  = $parser->parse_file($params->{'stylesheet'});
    my $stylesheet = $xslt->parse_stylesheet($style_doc);

    $self->_xslt($stylesheet);

    return;
}

sub transform {

    my ( $self, @xml ) = @_;

    my $parser   = XML::LibXML->new();
    my $combined = XML::LibXML::Document->new();
    my $xmlroot  = $combined->createElement('ClinStudyML');
    $combined->setDocumentElement($xmlroot);
    my $patients = $combined->createElement('Patients');
    $xmlroot->addChild($patients);

    foreach my $xmlfile ( @xml ) {

        my $source  = $parser->parse_file($xmlfile);
        my $results = $self->_xslt()->transform($source);

        my $newroot = $results->getDocumentElement();

        foreach my $group ( $newroot->getChildrenByLocalName('Patients') ) {
            foreach my $patient ( $group->getChildrenByLocalName('Patient') ) {
                $patients->addChild($patient->cloneNode(1));
            }
        }
    }

    return($combined);
}

sub postprocess {

    my ( $self, $doc ) = @_;

    my $root = $doc->getDocumentElement();

    foreach my $group ( $root->getChildrenByLocalName('Patients') ) {
        foreach my $patient ( $group->getChildrenByLocalName('Patient') ) {
            $self->_clean_patient( $patient );
        }
    }

    # A final run-through to remove all zero-length attributes, since
    # we've defined a strict schema that disallows them. This is such
    # a trivial step here that I think it's reasonable to require
    # this.
    foreach my $empty ( $root->findnodes('.//*[@*=""]') ) {
        $empty->unbindNode();
    }

    $root->setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
    $root->setAttribute('xsi:noNamespaceSchemaLocation', 'clindb.xsd');

    return $doc;
}

sub _uk_date_to_iso {

    my ( $self, $date ) = @_;

    # We use Date::Manip since it covers the widest range of
    # formats. Assumes UK date format (see Date_Init). Note that
    # incomplete dates will be assumed to be on the first of whatever
    # is missing (i.e. 1982 -> 1982-01-01).
    my $dateobj = ParseDate( $date )
        or die(qq{Error: Unable to parse date "$date".\n});

    my $isodate = $self->_dateobj_to_iso( $dateobj )
        or die(qq{Error: cannot parse day, month and year fields from "$date".\n});

    return $isodate;
}

sub _dateobj_to_iso {

    my ( $self, $dateobj ) = @_;

    my $d = UnixDate($dateobj, '%d');
    my $m = UnixDate($dateobj, '%m');
    my $y = UnixDate($dateobj, '%Y');

    return unless ( scalar ( grep { defined $_ } $d, $m, $y ) == 3 );

    my $date = sprintf("%04d-%02d-%02d", $y, $m, $d);

    return( $date );
}

sub _date_map_containers {

    my ( $self, $patient ) = @_;

    my %visit;
    foreach my $v ( $patient->findnodes('./Visits/Visit') ) {
        if ( my $date = $v->getAttribute('date') ) {
            $visit{ $date } = $v;
        }
        else {
            warn("Warning: Visit found without a date.\n");
        }
    }
    my %hospitalisation;
    foreach my $h ( $patient->findnodes('./Hospitalisations/Hospitalisation') ) {
        if ( my $date = $h->getAttribute('date') ) {
            $hospitalisation{ $date } = $h;
        }
        else {
            warn("Warning: Hospitalisation found without a date.\n");
        }
    }
    my %prior;
    foreach my $p ( $patient->findnodes('./PriorTreatments/PriorTreatment') ) {
        if ( my $date = $p->getAttribute('date') ) {
            $prior{ $date } = $p;
        }

        # No warning for PriorTreatment without a date, since it's such a common event.
    }

    # This defines the priority order for rehoming nodes.
    return ( \%visit, \%hospitalisation, \%prior );
}

sub _unbind_empty_testresult {

    my ( $self, $testresult ) = @_;

    # Depth-first clean out of any child test results.
    foreach my $child ( $testresult->findnodes('./ChildTestResults/TestResult') ) {
        $self->_unbind_empty_testresult( $child );
    }

    # Delete empty ChildTestResults container.
    foreach my $cont ( $testresult->findnodes('./ChildTestResults') ) {
        my @old = $cont->findnodes('./TestResult');
        if ( ! scalar @old ) {
            $cont->unbindNode();
        }
    }

    # Check on our current TestResult.
    my $value    = $testresult->getAttribute('value');
    my @children = $testresult->findnodes('./ChildTestResults/TestResult');
    unless ( ( defined $value && length $value && $value !~ /\bselect\b/i ) || scalar @children ) {
        $testresult->unbindNode();
        return 1;
    }

    return;
}

sub _rehome_node {

    my ( $self, $object, $new, $group ) = @_;

    $object->unbindNode();

    my @res = $new->findnodes('./' . $group);
    unless ( scalar @res ) {
        my $r = XML::LibXML::Element->new($group);
        $new->addChild($r);
        push @res, $r;
    }
    $res[0]->addChild($object);
    
    return;
}

sub _rehome_by_date {

    my ( $self, $object, $containers, $entry_date, $visit_group ) = @_;

    my $group = $object->nodeName() . 's';

    if ( my $date  = $object->getAttribute('date') ) {

        REHOME:
        foreach my $cont ( @$containers ) {

            if ( my $new = $cont->{$date} ) {

                $self->_rehome_node( $object, $new, $group );

                last REHOME;
            }
        }
    }
    elsif ( my $tp = $object->getAttribute('nominal_timepoint') ) {

        if ( my $cont = $self->_find_nearest_opportunity( $tp, $containers, $entry_date ) ) {
            $self->_rehome_node( $object, $cont, $group );
            $cont->setAttribute('nominal_timepoint', $tp);
        }
        else {

            # I guess we can assume we need to create a Visit if there
            # never were any to start with.
            my $target = $self->_calc_target_dateobj( $tp, $entry_date );
            my $vdate  = $self->_dateobj_to_iso( $target )
                or die(qq{Error converting Date object to ISO string ("$tp" after "$entry_date").\n});

            my $visit = XML::LibXML::Element->new('Visit');
            $visit_group->addChild($visit);
            $self->_rehome_node( $object, $visit, $group );
            $visit->setAttribute('date', $vdate);
            $visit->setAttribute('nominal_timepoint', $tp);
            $visit->setAttribute('notes', "Visit date inferred from the existence of $group");

            # The next line stops creation of duplicate visits
            # for the same timepoint, but without the threshold filter
            # in _find_nearest_opportunity it would also lead to
            # attachment of all objects to just one visit.            
            $containers->[0]{$vdate} = $visit;
        }

        my $attrs = $object->findnodes('./@nominal_timepoint');
        foreach my $attr ( $attrs->get_nodelist() ) {
            $attr->unbindNode();
        }
    }

    return;
}

sub _calc_target_dateobj {

    my ( $self, $tp, $entry_date ) = @_;

    my $delta = ParseDateDelta( $tp )
        or die(qq{Error: Unable to parse nominal_timepoint "$tp".\n});

    my $entry = ParseDate( $entry_date )
        or die(qq{Error: Unable to parse entry_date "$entry_date".\n});

    my $target = DateCalc( $entry, $delta )
        or die(qq{Error: Unable to calculate target date from "$entry_date" and "$tp".\n});

    return $target;
}

sub _find_nearest_opportunity {

    my ( $self, $tp, $containers, $entry_date ) = @_;

    my $target = $self->_calc_target_dateobj( $tp, $entry_date );

    my ( $best, $best_days );
    foreach my $cont ( @$containers ) {
        while ( my ( $date, $node ) = each %$cont ) {

            my $name = $node->nodeName();
            my $dateobj = ParseDate( $date )
                or die(qq{Error: Unable to parse $name date "$date".\n});

            my $diff = DateCalc( $dateobj, $target )
                or die(qq{Error: Unable to calculate delta between dates "$entry_date" and "$date".\n});

            my $days = abs(Delta_Format( $diff, 0, "%dh" ));

            if ( ! defined $best_days || $best_days > $days ) {
                $best_days = $days;
                $best      = $node;
            }
        }
    }

    # Fairly arbitrary filter to try and avoid mistakes.
    my $delta = ParseDateDelta( $tp )
        or die(qq{Error: Unable to parse nominal_timepoint "$tp".\n});
    my $threshold = ( (Delta_Format($delta, 0, "%Mt")/2) + 1 ) * 15;

    unless ( defined $best && $best_days < $threshold ) {
        warn(qq{Warnings: Unable to find an opportune container for "$tp" after "$entry_date".\n});
        return;
    }

    if ( defined $best_days && $best_days > 10 ) {
        warn(qq{Warning: Mapping "$tp" after "$entry_date" with a delta of $best_days days.\n});
    }

    return $best;
}

sub _clean_testresult {

    my ( $self, $testresult, $containers, $entry_date, $visit_group ) = @_;
            
    # If the result contains no data, just strip it out.
    return if $self->_unbind_empty_testresult($testresult);

    # Make sure child test results have the same date as the
    # parent. We only go one level deep for the sake of
    # efficiency.
    my $date     = $testresult->getAttribute('date') or return;
    my @children = $testresult->findnodes('./ChildTestResults/TestResult');
    foreach my $child ( @children ) {
        $child->setAttribute('date', $date);
    }

    $self->_rehome_by_date( $testresult, $containers, $entry_date, $visit_group );

    return;
}

sub _clean_drug {

    my ( $self, $drug, $containers, $entry_date, $visit_group ) = @_;

    # Split drugs into name and dosage. We'd ideally also
    # split out dose value, unit, frequency, duration etc. but
    # that's probably not practical.
    if ( my $name = $drug->getAttribute('name') ) {
        my ( $dname, $dose ) = split / +/, $name, 2;
        $drug->setAttribute('name', $dname);
        $drug->setAttribute('dose_regime', $dose) if defined $dose;
    }

    # Re-home the drug to visit/hosp/prior where possible.
    $self->_rehome_by_date( $drug, $containers, $entry_date, $visit_group );

    return;
}

sub _calculate_timepoint_date {

    my ( $self, $timepoint, $entry_date ) = @_;

    my $delta = ParseDateDelta($timepoint)
        or die(qq{Error: Unable to parse nominal_timepoint "$timepoint".\n});

    my $date = DateCalc( $entry_date, $delta )
        or die(qq{Error: Unable to parse entry_date "$entry_date".\n});

    my $isodate = $self->_dateobj_to_iso( $date )
        or die(qq{Error: Unable to calculate timepoint date ($timepoint after $entry_date).\n});

    return $isodate;
}

sub _clean_empty_container {

    my ( $self, $parent, $group ) = @_;

    foreach my $cont ( $parent->findnodes($group) ) {
        my @old = $cont->findnodes('./' . $group);
        if ( ! scalar @old ) {
            $cont->unbindNode();
        }
    }

    return;
}

sub _clean_patient {

    my ( $self, $patient ) = @_;

    my $entry_date = $patient->getAttribute('entry_date')
        or die("Error: Patient found without an entry date.\n");

    # Fix all our dates globally to be in YYYY-MM-DD
    foreach my $attrname ( qw(date start_date end_date entry_date) ) {
        my $attrs = $patient->findnodes('.//@' . $attrname);
        foreach my $attr ( $attrs->get_nodelist() ) {
            my $val = $attr->getValue();
            if ( length( $val ) > 0 && $val !~ $IS_NA_REGEXP ) {
                $attr->setValue( $self->_uk_date_to_iso( $val ) );
            }
            else {
                $attr->unbindNode();
            }
        }
    }

    # Split patient name into firstname/surname.
    if ( my $name = $patient->getAttribute('name') ) {

        # Don't record the names; anonymity prevails...
        $patient->removeAttribute('name')
    }

    # First, collect all the candidate TestResult and Drug parent elements.
    my @containers = $self->_date_map_containers( $patient );

    # We just take the first visit group as a point of attachment for
    # otherwise orphaned drugs/test results.
    my $visit_group = ( $patient->findnodes('./Visits') )[0];

    # Reattach drugs to the appropriate Visit.
    foreach my $drug ( $patient->findnodes('Drugs/Drug') ) {
        $self->_clean_drug( $drug, \@containers, $entry_date, $visit_group );
    }

    # Delete any old container nodes if they're empty.
    $self->_clean_empty_container( $patient, 'Drugs' );

    # Reattach test results to the appropriate Visit.
    foreach my $testresult ( $patient->findnodes('TestResults/TestResult') ) {
        $self->_clean_testresult( $testresult, \@containers, $entry_date, $visit_group );
    }

    # Delete any old container nodes if they're empty.
    $self->_clean_empty_container( $patient, 'TestResults' );

    # DiseaseEvent nominal_timepoint conversion to start_date. Note
    # that if start_date is already present we just remove the
    # unwanted attribute; if nominal_timepoint is empty or NA we
    # delete the entire DiseaseEvent since it's not a complete
    # remission (partial remission is given by either disease_activity
    # or the raw test scores, we don't need a third place for it!).
    EVENT:
    foreach my $event ( $patient->findnodes('./DiseaseEvents/DiseaseEvent') ) {

        my $date = $event->getAttribute('start_date');
        if ( defined $date && length $date && $date !~ $IS_NA_REGEXP ) {

            # Date looks good; we remove any nominal_timepoint attrs and move along.
            foreach my $nom ( $event->findnodes('@nominal_timepoint') ) {
                $nom->unbindNode();
            }
            next EVENT;
        }

        my $timepoint = $event->getAttribute('nominal_timepoint');
        if ( defined $timepoint && length $timepoint && $timepoint !~ $IS_NA_REGEXP ) {

            # Any nominal_timepoint is assumed to relate to complete remission/relapse.
            my $date = $self->_calculate_timepoint_date( $timepoint, $entry_date );
            $event->setAttribute('start_date', $date);
            foreach my $nom ( $event->findnodes('@nominal_timepoint') ) {
                $nom->unbindNode();
            }
            next EVENT;            
        }

        # No date or timepoint means this is almost certainly junk, or
        # a partial which doesn't belong in DiseaseEvent.
        $event->unbindNode();
        
    }

    # Delete any old container nodes if they're empty.
    $self->_clean_empty_container( $patient, 'DiseaseEvents' );

    return;
}

1;

__END__

=head1 NAME

ClinStudy::XML::Infopath - Perl extension for converting Infopath files to ClinStudy XML.

=head1 SYNOPSIS

 use ClinStudy::XML::Infopath;
 my $c = ClinStudy::XML::Infopath->new(stylesheet => $stylesheet_file);
 my $doc   = $c->transform($infopath_file);
 my $valid = $c->postprocess($doc);

=head1 DESCRIPTION

Module handling the conversion of Microsoft Infopath XML documents
into the ClinStudy XML Schema. This process takes the form of a fairly
straightforward XSLT transformation followed by a postprocessing step
which cleans up some of the uglier details. This latter step is
generally concerned with linking e.g. Visits with Drug treatments,
where dates may be given in multiple formats or simply expressed as a
nominal timepoint. In other words, if there are dragons anywhere in
the code they will be here.

=head2 EXPORT

None by default.

=head1 SEE ALSO

ClinStudy::XML::Schema

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

