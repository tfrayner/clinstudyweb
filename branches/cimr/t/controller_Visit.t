use strict;
use warnings;
use Test::More tests => 9;

use lib 't/lib';
use CSWTestLib;

BEGIN { use_ok 'Catalyst::Test', 'ClinStudy::Web' }
BEGIN { use_ok 'ClinStudy::Web::Controller::Visit' }

use HTTP::Request::Common;
my $login = request POST '/login', [ username=>'admin', password=>'admin', login=>1 ];
is( $login->code, 302, 'Login action should exist but redirects (302)' );

is( request('/visit')->code, 403,        'Index action should exist but be blocked (403)'  );
is( request('/visit/list')->code, 403,   'List action should exist but be blocked (403)'   );
is( request('/visit/view')->code, 403,   'View action should exist but be blocked (403)'   );
is( request('/visit/edit')->code, 403,   'Edit action should exist but be blocked (403)'   );
is( request('/visit/search')->code, 403, 'Search action should exist but be blocked (403)' );
is( request('/visit/delete')->code, 403, 'Delete action should exist but be blocked (403)' );


