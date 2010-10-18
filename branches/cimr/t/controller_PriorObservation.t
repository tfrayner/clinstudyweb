use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::PriorObservation' }

ok( request('/priorobservation')->is_success,        'Index request should succeed'  );
ok( request('/priorobservation/list')->is_success,   'List request should succeed'   );
ok( request('/priorobservation/view')->is_success,   'View request should succeed'   );
ok( request('/priorobservation/edit')->is_success,   'Edit request should succeed'   );
ok( request('/priorobservation/search')->is_success, 'Search request should succeed' );
ok( request('/priorobservation/delete')->is_success, 'Delete request should succeed' );


