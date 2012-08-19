use strict;
use warnings;
use Test::More tests => 2;


use Catalyst::Test 'ClinStudy::Web';
use ClinStudy::Web::Controller::Static;

# This turns out to be quite an important check:
is( request('/static')->code, 403, 'Index action should exist but be blocked (403)' );
is( request('/static/favicon')->code, 403, 'favicon action should exist but be blocked (403)' );
