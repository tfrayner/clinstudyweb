use strict;
use warnings;
use Test::More tests => 7;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Assay' }

ok( request('/assay')->is_success,        'Index request should succeed'  );
ok( request('/assay/list')->is_success,   'List request should succeed'   );
ok( request('/assay/view')->is_success,   'View request should succeed'   );
ok( request('/assay/edit')->is_success,   'Edit request should succeed'   );
ok( request('/assay/search')->is_success, 'Search request should succeed' );
#ok( request('/assay/delete')->is_success, 'Delete request should succeed' );

