#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;
use Test::More;

use lib 't/lib';
use CSWTestLib;

{
    use Test::DBIx::Class qw(:resultsets);

    reset_schema;

    Schema->bootstrap_journal;

    fixtures_ok 'patient'
        => 'installed the patient fixtures';

    ok my $patient = Patient->find({trial_id => 100})
        => 'can find patient';

    is_fields [qw(entry_date)], $patient, ['2008-01-01']
        => 'with the appropriate entry_date';

    ok my $visit = Visit->find({date => '2009-10-11'})
        => 'can find visit';

    eq_result $patient, $visit->patient_id()
        => 'linked to the right patient';

    done_testing();
};

