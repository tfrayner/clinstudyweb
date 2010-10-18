use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::AssayBatch' }

ok( request('/assaybatch')->is_success,        'Index request should succeed'  );
ok( request('/assaybatch/list')->is_success,   'List request should succeed'   );
ok( request('/assaybatch/view')->is_success,   'View request should succeed'   );
ok( request('/assaybatch/edit')->is_success,   'Edit request should succeed'   );
ok( request('/assaybatch/search')->is_success, 'Search request should succeed' );
ok( request('/assaybatch/delete')->is_success, 'Delete request should succeed' );
