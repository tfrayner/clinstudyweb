use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::TermSource' }

ok( request('/termsource')->is_success,        'Index request should succeed'  );
ok( request('/termsource/list')->is_success,   'List request should succeed'   );
ok( request('/termsource/view')->is_success,   'View request should succeed'   );
ok( request('/termsource/edit')->is_success,   'Edit request should succeed'   );
ok( request('/termsource/search')->is_success, 'Search request should succeed' );
ok( request('/termsource/delete')->is_success, 'Delete request should succeed' );
