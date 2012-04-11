use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ClinStudy::Web';
use ClinStudy::Web::Controller::Static;

ok( request('/static')->is_success, 'Request should succeed' );
done_testing();
