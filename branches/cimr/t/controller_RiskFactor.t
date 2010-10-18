use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::RiskFactor' }

ok( request('/riskfactor')->is_success,        'Index request should succeed'  );
ok( request('/riskfactor/list')->is_success,   'List request should succeed'   );
ok( request('/riskfactor/view')->is_success,   'View request should succeed'   );
ok( request('/riskfactor/edit')->is_success,   'Edit request should succeed'   );
ok( request('/riskfactor/search')->is_success, 'Search request should succeed' );
ok( request('/riskfactor/delete')->is_success, 'Delete request should succeed' );


