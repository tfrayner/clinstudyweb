use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::EmergentGroup' }

ok( request('/emergentgroup')->is_success,        'Index request should succeed'  );
ok( request('/emergentgroup/list')->is_success,   'List request should succeed'   );
ok( request('/emergentgroup/view')->is_success,   'View request should succeed'   );
ok( request('/emergentgroup/edit')->is_success,   'Edit request should succeed'   );
ok( request('/emergentgroup/search')->is_success, 'Search request should succeed' );
ok( request('/emergentgroup/delete')->is_success, 'Delete request should succeed' );


