use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ClinStudy::Web';
use ClinStudy::Web::Controller::PhenotypeQuantity;

ok( request('/phenotypequantity')->is_success, 'Request should succeed' );
done_testing();
