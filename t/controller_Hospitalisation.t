use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Hospitalisation' }

ok( request('/hospitalisation')->is_success,        'Index request should succeed'  );
ok( request('/hospitalisation/list')->is_success,   'List request should succeed'   );
ok( request('/hospitalisation/view')->is_success,   'View request should succeed'   );
ok( request('/hospitalisation/edit')->is_success,   'Edit request should succeed'   );
ok( request('/hospitalisation/search')->is_success, 'Search request should succeed' );
ok( request('/hospitalisation/delete')->is_success, 'Delete request should succeed' );


