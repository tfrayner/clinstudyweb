use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Patient' }

ok( request('/patient')->is_success,        'Index request should succeed'  );
ok( request('/patient/list')->is_success,   'List request should succeed'   );
ok( request('/patient/view')->is_success,   'View request should succeed'   );
ok( request('/patient/edit')->is_success,   'Edit request should succeed'   );
ok( request('/patient/search')->is_success, 'Search request should succeed' );
ok( request('/patient/delete')->is_success, 'Delete request should succeed' );


