use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::SampleDataFile' }

ok( request('/sampledatafile')->is_success, 'Request should succeed' );
done_testing();
