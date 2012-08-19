use strict;
use warnings;
use Test::More tests => 6;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::User' }

is( request('/user')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/user/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/user/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/user/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


