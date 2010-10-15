use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Diagnosis' }

ok( request('/diagnosis')->is_success,        'Index request should succeed'  );
ok( request('/diagnosis/list')->is_success,   'List request should succeed'   );
ok( request('/diagnosis/view')->is_success,   'View request should succeed'   );
ok( request('/diagnosis/edit')->is_success,   'Edit request should succeed'   );
ok( request('/diagnosis/search')->is_success, 'Search request should succeed' );
ok( request('/diagnosis/delete')->is_success, 'Delete request should succeed' );


