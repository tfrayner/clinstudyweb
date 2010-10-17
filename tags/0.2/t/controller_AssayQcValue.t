use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::AssayQcValue' }

ok( request('/assayqcvalue')->is_success,        'Index request should succeed'  );
ok( request('/assayqcvalue/list')->is_success,   'List request should succeed'   );
ok( request('/assayqcvalue/view')->is_success,   'View request should succeed'   );
ok( request('/assayqcvalue/edit')->is_success,   'Edit request should succeed'   );
ok( request('/assayqcvalue/search')->is_success, 'Search request should succeed' );
ok( request('/assayqcvalue/delete')->is_success, 'Delete request should succeed' );


