use strict;
use warnings;
use Test::More tests => 18;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Query' }

is( request('/query')->code, 403,                  'Index action should exist but be blocked (403)' );
is( request('/query/assay_dump')->code, 403,       'assay_dump action should exist but be blocked (403)' );
is( request('/query/sample_dump')->code, 403,      'sample_dump action should exist but be blocked (403)' );
is( request('/query/assay_drugs')->code, 403,      'assay_drugs action should exist but be blocked (403)' );
is( request('/query/list_tests')->code, 403,       'list_tests action should exist but be blocked (403)' );
is( request('/query/list_phenotypes')->code, 403,  'list_phenotypes action should exist but be blocked (403)' );
is( request('/query/patient_entry_date')->code, 403, 'patient_entry_date action should exist but be blocked (403)' );
is( request('/query/visit_dates')->code, 403,      'visit_dates action should exist but be blocked (403)' );
is( request('/query/patients')->code, 403,         'patients action should exist but be blocked (403)' );
is( request('/query/visits')->code, 403,           'visits action should exist but be blocked (403)' );
is( request('/query/samples')->code, 403,          'samples action should exist but be blocked (403)' );
is( request('/query/assays')->code, 403,           'assays action should exist but be blocked (403)' );
is( request('/query/transplants')->code, 403,      'transplants action should exist but be blocked (403)' );
is( request('/query/prior_treatments')->code, 403, 'prior_treatments action should exist but be blocked (403)' );
ok( request('/json_login')->is_success,  'JSON login action should succeed' );
is( request('/json_logout')->code, 403,  'JSON logout action should exists but be blocked (403)' );
