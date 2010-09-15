use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::DiseaseEvent' }

ok( request('/diseaseevent')->is_success,        'Index request should succeed'  );
ok( request('/diseaseevent/list')->is_success,   'List request should succeed'   );
ok( request('/diseaseevent/view')->is_success,   'View request should succeed'   );
ok( request('/diseaseevent/edit')->is_success,   'Edit request should succeed'   );
ok( request('/diseaseevent/search')->is_success, 'Search request should succeed' );
ok( request('/diseaseevent/delete')->is_success, 'Delete request should succeed' );


