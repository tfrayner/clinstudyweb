use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Visit' }

ok( request('/visit')->is_success,        'Index request should succeed'  );
ok( request('/visit/list')->is_success,   'List request should succeed'   );
ok( request('/visit/view')->is_success,   'View request should succeed'   );
ok( request('/visit/edit')->is_success,   'Edit request should succeed'   );
ok( request('/visit/search')->is_success, 'Search request should succeed' );
ok( request('/visit/delete')->is_success, 'Delete request should succeed' );


