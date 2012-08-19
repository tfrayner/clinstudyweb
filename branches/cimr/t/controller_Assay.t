use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Assay' }

is( request('/assay')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/assay/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/assay/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/assay/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/assay/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/assay/delete')->code, 404, 'Delete action should not exist' );


