use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::ControlledVocab' }

is( request('/controlledvocab')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/controlledvocab/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/controlledvocab/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/controlledvocab/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/controlledvocab/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/controlledvocab/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


