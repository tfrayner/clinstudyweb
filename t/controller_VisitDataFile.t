use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::VisitDataFile' }

ok( request('/visitdatafile')->is_success, 'Request should succeed' );
done_testing();
