use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::ControlledVocab' }

ok( request('/controlledvocab')->is_success, 'Request should succeed' );


