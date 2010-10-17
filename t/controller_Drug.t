use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Drug' }

ok( request('/drug')->is_success,        'Index request should succeed'  );
ok( request('/drug/list')->is_success,   'List request should succeed'   );
ok( request('/drug/view')->is_success,   'View request should succeed'   );
ok( request('/drug/edit')->is_success,   'Edit request should succeed'   );
ok( request('/drug/search')->is_success, 'Search request should succeed' );
ok( request('/drug/delete')->is_success, 'Delete request should succeed' );


