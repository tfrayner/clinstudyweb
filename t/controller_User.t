use strict;
use warnings;
use Test::More tests => 6;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::User' }

ok( request('/user')->is_success,        'Index request should succeed'  );
ok( request('/user/list')->is_success,   'List request should succeed'   );
ok( request('/user/edit')->is_success,   'Edit request should succeed'   );
ok( request('/user/delete')->is_success, 'Delete request should succeed' );


