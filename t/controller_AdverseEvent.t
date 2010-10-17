use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::AdverseEvent' }

ok( request('/adverseevent')->is_success,        'Index request should succeed'  );
ok( request('/adverseevent/list')->is_success,   'List request should succeed'   );
ok( request('/adverseevent/view')->is_success,   'View request should succeed'   );
ok( request('/adverseevent/edit')->is_success,   'Edit request should succeed'   );
ok( request('/adverseevent/search')->is_success, 'Search request should succeed' );
ok( request('/adverseevent/delete')->is_success, 'Delete request should succeed' );


