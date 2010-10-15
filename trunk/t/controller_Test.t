use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Test' }

ok( request('/test')->is_success,        'Index request should succeed'  );
ok( request('/test/list')->is_success,   'List request should succeed'   );
ok( request('/test/view')->is_success,   'View request should succeed'   );
ok( request('/test/edit')->is_success,   'Edit request should succeed'   );
ok( request('/test/search')->is_success, 'Search request should succeed' );
ok( request('/test/delete')->is_success, 'Delete request should succeed' );
