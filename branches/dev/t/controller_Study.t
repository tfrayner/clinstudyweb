use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Study' }

is( request('/study')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/study/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/study/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/study/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/study/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/study/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


