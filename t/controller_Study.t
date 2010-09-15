use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Study' }

ok( request('/study')->is_success,        'Index request should succeed'  );
ok( request('/study/list')->is_success,   'List request should succeed'   );
ok( request('/study/view')->is_success,   'View request should succeed'   );
ok( request('/study/edit')->is_success,   'Edit request should succeed'   );
ok( request('/study/search')->is_success, 'Search request should succeed' );
ok( request('/study/delete')->is_success, 'Delete request should succeed' );


