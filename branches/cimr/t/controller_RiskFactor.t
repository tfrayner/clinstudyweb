use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::RiskFactor' }

is( request('/riskfactor')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/riskfactor/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/riskfactor/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/riskfactor/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/riskfactor/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/riskfactor/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


