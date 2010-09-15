use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::PriorTreatment' }

ok( request('/priortreatment')->is_success,        'Index request should succeed'  );
ok( request('/priortreatment/list')->is_success,   'List request should succeed'   );
ok( request('/priortreatment/view')->is_success,   'View request should succeed'   );
ok( request('/priortreatment/edit')->is_success,   'Edit request should succeed'   );
ok( request('/priortreatment/search')->is_success, 'Search request should succeed' );
ok( request('/priortreatment/delete')->is_success, 'Delete request should succeed' );


