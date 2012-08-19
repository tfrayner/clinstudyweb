use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Transplant' }

is( request('/transplant')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/transplant/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/transplant/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/transplant/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/transplant/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/transplant/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


