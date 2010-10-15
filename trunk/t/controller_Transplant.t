use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Transplant' }

ok( request('/transplant')->is_success,        'Index request should succeed'  );
ok( request('/transplant/list')->is_success,   'List request should succeed'   );
ok( request('/transplant/view')->is_success,   'View request should succeed'   );
ok( request('/transplant/edit')->is_success,   'Edit request should succeed'   );
ok( request('/transplant/search')->is_success, 'Search request should succeed' );
ok( request('/transplant/delete')->is_success, 'Delete request should succeed' );


