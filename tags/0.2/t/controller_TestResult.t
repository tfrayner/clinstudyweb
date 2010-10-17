use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::TestResult' }

ok( request('/testresult')->is_success,        'Index request should succeed'  );
ok( request('/testresult/list')->is_success,   'List request should succeed'   );
ok( request('/testresult/view')->is_success,   'View request should succeed'   );
ok( request('/testresult/edit')->is_success,   'Edit request should succeed'   );
ok( request('/testresult/search')->is_success, 'Search request should succeed' );
ok( request('/testresult/delete')->is_success, 'Delete request should succeed' );


