use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::ControlledVocab' }

ok( request('/controlledvocab')->is_success,        'Index request should succeed'  );
ok( request('/controlledvocab/list')->is_success,   'List request should succeed'   );
ok( request('/controlledvocab/view')->is_success,   'View request should succeed'   );
ok( request('/controlledvocab/edit')->is_success,   'Edit request should succeed'   );
ok( request('/controlledvocab/search')->is_success, 'Search request should succeed' );
ok( request('/controlledvocab/delete')->is_success, 'Delete request should succeed' );


