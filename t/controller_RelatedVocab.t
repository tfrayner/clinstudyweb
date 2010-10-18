use strict;
use warnings;
use Test::More tests => 8;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::RelatedVocab' }

ok( request('/relatedvocab')->is_success,        'Index request should succeed'  );
ok( request('/relatedvocab/list')->is_success,   'List request should succeed'   );
ok( request('/relatedvocab/view')->is_success,   'View request should succeed'   );
ok( request('/relatedvocab/edit')->is_success,   'Edit request should succeed'   );
ok( request('/relatedvocab/search')->is_success, 'Search request should succeed' );
ok( request('/relatedvocab/delete')->is_success, 'Delete request should succeed' );


