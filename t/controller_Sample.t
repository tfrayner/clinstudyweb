use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Sample' }

ok( request('/sample')->is_success,        'Index request should succeed'  );
ok( request('/sample/list')->is_success,   'List request should succeed'   );
ok( request('/sample/view')->is_success,   'View request should succeed'   );
ok( request('/sample/edit')->is_success,   'Edit request should succeed'   );
ok( request('/sample/search')->is_success, 'Search request should succeed' );
ok( request('/sample/delete')->is_success, 'Delete request should succeed' );


