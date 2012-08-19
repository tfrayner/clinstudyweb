use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::TestResult' }

is( request('/testresult')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/testresult/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/testresult/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/testresult/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/testresult/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/testresult/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


