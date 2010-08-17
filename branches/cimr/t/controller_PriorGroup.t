use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::PriorGroup' }

ok( request('/priorgroup')->is_success, 'Request should succeed' );


