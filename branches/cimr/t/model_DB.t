#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;
use Test::More;

{
    use Test::DBIx::Class qw(:resultsets);

    fixtures_ok 'patient'
        => 'installed the patient fixtures';

    ok my $patient = Patient->find({surname => 'Smith'})
        => 'can find patient';

    is_fields [qw(surname firstname)], $patient, ['Smith', 'John']
        => 'with the appropriate name';

    ok my $visit = Visit->find({date => '2009-10-11'})
        => 'can find visit';

    eq_result $patient, $visit->patient_id()
        => 'linked to the right patient';

    done_testing();
};

