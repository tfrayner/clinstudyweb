use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'CIMR::ClinWeb' }
BEGIN { use_ok 'CIMR::ClinWeb::Controller::Comorbidity' }

ok( request('/comorbidity')->is_success, 'Request should succeed' );


