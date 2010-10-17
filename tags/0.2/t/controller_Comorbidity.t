use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Comorbidity' }

ok( request('/comorbidity')->is_success,        'Index request should succeed'  );
ok( request('/comorbidity/list')->is_success,   'List request should succeed'   );
ok( request('/comorbidity/view')->is_success,   'View request should succeed'   );
ok( request('/comorbidity/edit')->is_success,   'Edit request should succeed'   );
ok( request('/comorbidity/search')->is_success, 'Search request should succeed' );
ok( request('/comorbidity/delete')->is_success, 'Delete request should succeed' );


