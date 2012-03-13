#
# This file is part of BeerFestDB, a beer festival product management
# system.
# 
# Copyright (C) 2010 Tim F. Rayner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package ClinStudy::Web::Controller::Query;
use Moose;
use namespace::autoclean;

use List::Util qw(first);
use Date::Calc qw(Date_to_Days);
require JSON::Any;
require DateTime;
require DateTime::Format::MySQL;

BEGIN {extends 'Catalyst::Controller'; }

# Set a query flag which can be used to ask for more detail in
# returned data.
my $EXTENDED_FLAG = 'include_relationships';

=head1 NAME

ClinStudy::Web::Controller::Query - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller providing JSON-based queries of the
database. There are two main approaches which are supported by this
module:

=head2 "Canned" queries

This query mechanism is likely to be the more useful of the two
approaches, and will usually take less time and complexity to retrieve
the desired information. The module makes a series of actions
available (e.g. 'patients', 'visits'), each of which take a set list
of optional query parameters and use them to retrieve predefined
chunks of data. Each query parameter can include the wildcard
characters '*' and '?', and the query may consist of a list of such
terms. For example, the following JSON would be a valid 'patients' query:

 {
   "study":"IBD",
   "trial_id":["V10?","T3*","X495"],
   "include_relationships":"1"
 }

Note that such a query would combine all trial_id terms using OR,
followed by the inclusion of other search terms using AND.

The 'include_relationships' flag is deserving of a special mention. By
default the query returns only those data which are directly contained
in the database table of interest (in this case, "patient"). However,
if 'include_relationships' is set to a defined value, all the linked
database tables are queried and far more information is returned.

=head2 Low level generic queries

In those cases which are not easily addressed using the canned query
mechanism, this module also allows for completely generic database
queries in the spirit of the Perl module SQL::Abstract. See below for
details.

=head1 AUTHENTICATION API

=cut

=head2 json_login

This is the primary authentication method which is to be used prior to
any other queries in order to obtain an authenticated connection. See
e.g. the curl documentation for details on how this may be used (an RCurl
example is available in the associated ClinStudyWeb R package). Success
or failure is denoted by a boolean "success" flag in the returned
object.

=cut

sub json_login : Global {

    my ( $self, $c ) = @_;

    # Here $query is a hashref with keys username and password.
    my $query = $self->_decode_json( $c );

    # This is stupidly explicit, considering, but may help avoid
    # mistakes in future.
    if ( $c->authenticate({ username => $query->{'username'},
                            password => $query->{'password'}, }) ) {

        # Note that we're deliberately not setting the access date
        # here; read-only programmatic access is not of much interest
        # for audit purposes. Perhaps revisit this if we ever allow
        # read-write access in the JSON API.

        $c->stash->{ 'success' } = JSON::Any->true();
    }
    else {
        $c->stash->{ 'errorMessage' } = qq{Error: Unable to authenticate.};
        $c->stash->{ 'success' } = JSON::Any->false();
    }

    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head2 json_logout

A method which simply deauthenticates the user.

=cut

sub json_logout : Global {

    my ( $self, $c ) = @_;

    # Whatever happens we want to log out.
    $c->logout;
    
    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head1 GENERIC QUERY API

=head2 index

This is the core of the generic JSON query API. JSON parameters are as
follows: resultSet, condition, attributes. These parameters are passed
in as a hashref named "data". Return values are similarly passed under
a "data" key. Success or failure is denoted by a boolean "success"
flag in the returned object.

Queries must be constructed in a form understandable by the
DBIx::Class::ResultSet search() method. In essence this means that the
query is to be broken down into a 'condition' hashref, containing the
components of an SQL WHERE clause encoded in a form supported by the
SQL::Abstract module, and an 'attributes' hashref which contains
further query qualifiers (most commonly, JOIN clauses). An example would be:

 $query = {
    resultSet  => 'Assay',
    condition  => { 'patient_id.trial_id' => $some_trial_id },
    attributes => { join => { channels => { sample_id => { visit_id => 'patient_id' }}}}
 };

This query would return all the assays linked to a patient having
trial_id=$some_trial_id. In principle it should be possible to
construct any desired query using this mechanism, although in practice
it may be easier and quicker to use the canned query API instead.

=cut

sub index : Path {

    my ( $self, $c ) = @_;

    # Here $query is a hashref with keys resultSet, cond and attrs.
    my $query = $self->_decode_json( $c );

    my $dbclass = $query->{ 'resultSet' };
    if ( ! $dbclass ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: No resultSet JSON query attribute specified.};
        $c->detach( $c->view( 'JSON' ) );
    }
    $dbclass =~ s/^(?:.*::)?/DB::/;

    # User privileges tables are off-limits
    if ( first { $_ eq $dbclass } qw( DB::User DB::Role DB::UserRole ) ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: JSON access to that table is not permitted.};
        $c->detach( $c->view( 'JSON' ) );
    }

    # This will generally refuse to fail, even if $dbclass is empty.
    my $rs = $c->model($dbclass);

    # Run the actual query.
    my $cond  = $query->{ 'condition' }  || {};
    my $attrs = $query->{ 'attributes' } || {};
    
    my @results;
    eval {
        @results = $rs->search( $cond, $attrs );
    };
    if ( $@ ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error in SQL query: $@};
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->true();

        # Just take the column values and put them in a hash for JSON encoding.
        my @hashes;
        foreach my $res ( @results ) {
            push @hashes, { $res->get_columns() };
        }

        $c->stash->{ 'data' } = \@hashes;
    }
    
    $c->detach( $c->view( 'JSON' ) );

    return;        
}

=head1 MISCELLANEOUS QUERIES

=head2 assay_dump

A method used by the R client to annotate data sets. A candidate for
deprecation, this method may be replaced in future by calls to the
canned query API. Use at your own risk.

=cut

sub assay_dump : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Assay');

    my ( $assay, $id );
    if ( defined ( $id = $query->{filename} ) ) {
        $assay = $rs->find({ filename => $id });
    }
    elsif ( defined ( $id = $query->{identifier} ) ) {
        $assay = $rs->find({ identifier => $id });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include either filename or identifier.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $assay ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' } = $self->dump_assay_entity($c, $assay, $query);
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Assay "$id" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 sample_dump

A method used by the R client to annotate data sets. A candidate for
deprecation, this method may be replaced in future by calls to the
canned query API. Use at your own risk.

=cut

sub sample_dump : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Sample');
    my ( $sample, $name );
    if ( defined ( $name = $query->{name} ) ) {
        $sample = $rs->find({ name => $name });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include sample name.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $sample ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' } = $self->dump_sample_entity($c, $sample, $query);
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Sample "$name" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 assay_drugs

A method used to retrieve drug information linked to a set of
assays. Query terms are 'filename' or 'identifier' (one of these is
required), and the optional terms 'prior_treatment_type',
'months_prior' and 'drug_type' which can be used to limit the scope of
the search. For example, one might search for drug treatments using an
immunosuppressant drug type, up to 6 months prior to the visit related
to this assay.

=cut

sub assay_drugs : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Assay');

    my ( $assay, $id );
    if ( defined ( $id = $query->{filename} ) ) {
        $assay = $rs->find({ filename => $id });
    }
    elsif ( defined ( $id = $query->{identifier} ) ) {
        $assay = $rs->find({ identifier => $id });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include either filename or identifier.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $assay ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' } = $self->dump_assay_drugs($c, $assay, $query);
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Assay "$id" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

## Note that the next few actions could all be implemented via the
## index query action, but at a cost of greater complexity in the
## client. Since these are core use cases we make them easier to use.

=head2 list_tests

Simple method to return a list of test names and database IDs;
originally designed for use with the annotation picker Tcl/Tk
interface in the R client. Takes an optional 'pattern' argument which
can use '*' and '?' wildcards to filter the results. A 'retrieve_all'
argument is also available which, when set to a non-zero value, will
retrieve all tests. The default is to return only those tests which
are not children of other test types; this is far more often the
desired result.

=cut

sub list_tests : Local {

    my ( $self, $c ) = @_;

    my $query;
    $query = $self->_decode_json( $c ) if defined $c->request->param( 'data' );

    my $rs = $c->model('DB::Test');

    my ( $pattern, $tests );

    # We allow a query pattern to be used as a filter, but for the
    # most part this will just dump all test names.
    if ( defined ( $pattern = $query->{pattern} ) ) {
        $pattern =~ s/([_%])/\\$1/g;
        $pattern =~ tr(*?)(%_);
        $tests   = $rs->search({ name => { -like => $pattern }});
    }
    else {
        $tests   = $rs;
    }

    my $result = {};
    TEST:
    while ( my $test = $tests->next() ) {

        # Skip tests which are children of other tests (unless specifically requested).
        unless ( $query->{retrieve_all} ) {
            next TEST if $test->search_related('test_results')
                              ->search_related('test_aggregation_test_result_ids')->count();
        }

        $result->{ $test->name() } = $test->id();
    }

    $c->stash->{ 'success' } = JSON::Any->true();
    $c->stash->{ 'data' }    = $result;

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 list_phenotypes

Simple method to return a list of phenotype quantities and database
IDs; originally designed for use with the annotation picker Tcl/Tk
interface in the R client. Takes an optional 'pattern' argument which
can use '*' and '?' wildcards to filter the results.

=cut

sub list_phenotypes : Local {

    my ( $self, $c ) = @_;

    my $query;
    $query = $self->_decode_json( $c ) if defined $c->request->param( 'data' );

    my $rs = $c->model('DB::PhenotypeQuantity');

    my ( $pattern, $pheno );

    # We allow a query pattern to be used as a filter, but for the
    # most part this will just dump all phenotype names.
    if ( defined ( $pattern = $query->{pattern} ) ) {
        $pattern =~ s/([_%])/\\$1/g;
        $pattern =~ tr(*?)(%_);
        $pheno   = $rs->search_related('type_id', { 'type_id.value' => { -like => $pattern }}, { distinct => 1 } );
    }
    else {
        $pheno   = $rs->search_related('type_id', undef, { distinct => 1 });
    }

    my $result = {};
    while ( my $ph = $pheno->next() ) {
        $result->{ $ph->value() } = $ph->id();
    }

    $c->stash->{ 'success' } = JSON::Any->true();
    $c->stash->{ 'data' }    = $result;

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 patient_entry_date

Method to return the entry date for a patient. Since this is not much
simpler than the corresponding canned query, this method may also be
deprecated in future. Query parameters: 'trial_id'.

=cut

sub patient_entry_date : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Patient');

    my ( $patient, $id );
    if ( defined ( $id = $query->{trial_id} ) ) {
        $patient = $rs->find({ trial_id => $id });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include trial_id.};
        $c->detach( $c->view( 'JSON' ) );
    }

    if ( $patient ) {
        $c->stash->{ 'success' } = JSON::Any->true();
        $c->stash->{ 'data' }    = $patient->entry_date();  ## Does this work FIXME?
    }
    else {
        $c->stash->{ 'success' }      = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Patient "$id" not found in database.};
    }

    $c->detach( $c->view( 'JSON' ) );

    return;
}

=head2 visit_dates

Method to retrieve all the visit dates for a given patient
('trial_id'), optionally filtered by nominal timepoint name
('timepoint'). Owing to its similarity with the corresponding visit
canned query method, this is likely to be deprecated in future.

=cut

sub visit_dates : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    my $rs = $c->model('DB::Visit');

    my $patient;
    my $trial_id  = $query->{trial_id};
    if ( defined $trial_id ) {
        $patient = $c->model('DB::Patient')->find({ trial_id => $trial_id });
    }
    else {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' }
            = qq{Error: JSON parameters must include trial_id.};
        $c->detach( $c->view( 'JSON' ) );
    }

    unless ( $patient ) {
        $c->stash->{ 'success' }      = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error: Patient "$trial_id" not found in database.};
        $c->detach( $c->view( 'JSON' ) );
    }

    my $timepoint = $query->{timepoint};

    my @visits;
    if ( defined $timepoint ) {
        @visits = $patient->search_related('visits',
                                           { 'nominal_timepoint_id.value' => $timepoint },
                                           { join => 'nominal_timepoint_id' })
    }
    else {
        @visits = $patient->visits();
    }

    # Dates may be an empty list. Beware bad timepoint CVs.
    my @dates = map { $_->date() } @visits;

    $c->stash->{ 'success' } = JSON::Any->true();
    $c->stash->{ 'data' }    = \@dates;
    $c->detach( $c->view( 'JSON' ) );

    return;
}

# New "canned" query API. This is intended as an "optimised" version of the
# generic JSON query API in that it will allow users to query just
# Patient, Visit, Sample, Assay and Transplant tables, pulling out all
# the data for a given entry. The idea is that the R client will
# aggregate data across table rows and return lists of data frames
# with useful entries. This could be implemented entirely via the
# generic JSON API but (a) that would be unnecessarily complex, and
# (b) I suspect it would be slower, simply because of the network
# overhead. We only support a defined subset of query terms here, and
# handle the joining complexity at this level rather than in the
# client.

=head1 CANNED QUERY API

All the following methods also accept the 'include_relationships' flag
as described above.

=head2 patients

Canned query method for patients. Available query terms include:

=over 2

=item trial_id

The patient trial ID. Not to be confused with 'id' below, which is the
internal database identifier.

=item id

The patient internal database ID. This is provided as a query term
purely for the sake of convenience.

=item study

The name of a study to which the patient must belong.

=item diagnosis

The name of a diagnosis which the patient must have received at some
point. Note that this queries all diagnoses, and not just the most
recent.

=back

=cut

sub patients : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    $self->_check_query_terms( $c, $query, [ qw(trial_id id study diagnosis) ] );

    my ( %cond, %attrs );
    $attrs{ 'join' } = [];
    $cond{ -and }    = [];
    
    foreach my $qterm ( qw(trial_id id) ) {
        if ( my $value = $query->{$qterm} ) {
            push @{ $cond{-and} },
                { -or => $self->_qterm_to_sqlabstract_like_in( $value, $qterm ) };
        }
    }
    if ( my $study = $query->{'study'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $study, 'type_id.value' ) };
        push @{ $attrs{ 'join' } }, { 'studies' => 'type_id' };
    }
    if ( my $diag = $query->{'diagnosis'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $diag, 'condition_name_id.value' ) };
        push @{ $attrs{ 'join' } }, { 'diagnoses' => 'condition_name_id' };
    }

    $self->_prepare_query_data_and_detach( $c, \%cond, \%attrs, 'Patient', $query->{$EXTENDED_FLAG} );
}

=head2 visits

Canned query method for clinic visits. Available query terms include:

=over 2

=item trial_id

The trial ID for the patient linked to the visit.

=item id

The internal visit database ID.

=item date

The visit date.

=item nominal_timepoint

The timepoint assigned to the visit.

=back

=cut

sub visits : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    $self->_check_query_terms( $c, $query, [ qw(trial_id id date nominal_timepoint) ] );

    my ( %cond, %attrs );
    $attrs{ 'join' } = [];
    $cond{ -and }    = [];
    
    foreach my $qterm ( qw(date id) ) {
        if ( my $value = $query->{$qterm} ) {
            push @{ $cond{-and} },
                { -or => $self->_qterm_to_sqlabstract_like_in( $value, $qterm ) };
        }
    }
    if ( my $trial_id = $query->{'trial_id'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $trial_id, 'patient_id.trial_id' ) };
        push @{ $attrs{ 'join' } }, 'patient_id';
    }
    if ( my $tpoint = $query->{'nominal_timepoint'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $tpoint, 'nominal_timepoint_id.value' ) };
        push @{ $attrs{ 'join' } }, 'nominal_timepoint_id';
    }

    $self->_prepare_query_data_and_detach( $c, \%cond, \%attrs, 'Visit', $query->{$EXTENDED_FLAG} );
}

=head2 samples

Canned query method for samples. Available query terms include:

=over 2

=item trial_id

The trial ID for the patient linked to the sample.

=item id

The sample internal database ID.

=item name

The sample name as recorded in the database. Note that this is often
not as useful as a combination of trial_id, date, cell_type and
material_type.

=item date

The date of the clinic visit for the sample.

=item cell_type

The controlled cell type term (e.g. "CD4").

=item material_type

The controlled material type term (e.g. "RNA").

=back

=cut

sub samples : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    $self->_check_query_terms( $c, $query, [ qw(id name trial_id date cell_type material_type) ] );

    my ( %cond, %attrs );
    $attrs{ 'join' } = [];
    $cond{ -and }    = [];
    
    foreach my $qterm ( qw(name id) ) {
        if ( my $value = $query->{$qterm} ) {
            push @{ $cond{-and} },
                { -or => $self->_qterm_to_sqlabstract_like_in( $value, $qterm ) };
        }
    }
    if ( my $trial_id = $query->{'trial_id'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $trial_id, 'patient_id.trial_id' ) };
        push @{ $attrs{ 'join' } }, { 'visit_id' => 'patient_id' };
    }
    if ( my $tpoint = $query->{'cell_type'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $tpoint, 'cell_type_id.value' ) };
        push @{ $attrs{ 'join' } }, 'cell_type_id';
    }
    if ( my $tpoint = $query->{'material_type'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $tpoint, 'material_type_id.value' ) };
        push @{ $attrs{ 'join' } }, 'material_type_id';
    }

    $self->_prepare_query_data_and_detach( $c, \%cond, \%attrs, 'Sample', $query->{$EXTENDED_FLAG} );
}

=head2 assays

Canned query method for assays. Available query terms include:

=over 2

=item id

The assay internal database ID.

=item sample_id

The internal database ID for samples used in the assay.

=item filename

The filename associated with the assay.

=item identifier

The assay identifier. This might be a barcode or other standardised
identifier depending on your local practice.

=item date

The date upon which the assay was performed.

=item batch

The name of the AssayBatch to which this assay belongs.

=back

=cut

sub assays : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    $self->_check_query_terms( $c, $query, [ qw(id filename identifier date batch sample_id) ] );

    my ( %cond, %attrs );
    $attrs{ 'join' } = [];
    $cond{ -and }    = [];
    
    foreach my $qterm ( qw(filename identifier id) ) {
        if ( my $value = $query->{$qterm} ) {
            push @{ $cond{-and} },
                { -or => $self->_qterm_to_sqlabstract_like_in( $value, $qterm ) };
        }
    }
    if ( my $date = $query->{'date'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $date, 'assay_batch_id.date' ) };
        push @{ $attrs{ 'join' } }, 'assay_batch_id';
    }
    if ( my $batch = $query->{'batch'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $batch, 'assay_batch_id.name' ) };
        push @{ $attrs{ 'join' } }, 'assay_batch_id';
    }
    if ( my $sample_id = $query->{'sample_id'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $sample_id, 'channels.sample_id' ) };
        push @{ $attrs{ 'join' } }, 'channels';
    }

    $self->_prepare_query_data_and_detach( $c, \%cond, \%attrs, 'Assay', $query->{$EXTENDED_FLAG} );
}

=head2 transplants

Canned query method for transplants. Available query terms include:

=over 2

=item trial_id

The trial ID for the patient linked to the transplant.

=item id

The internal transplant database ID.

=item date

The transplant date.

=item organ_type

The type of organ transplanted (e.g. "kidney").

=back

=cut

sub transplants : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    $self->_check_query_terms( $c, $query, [ qw(id trial_id date organ_type) ] );

    my ( %cond, %attrs );
    $attrs{ 'join' } = [];
    $cond{ -and }    = [];
    
    foreach my $qterm ( qw(date id) ) {
        if ( my $value = $query->{$qterm} ) {
            push @{ $cond{-and} },
                { -or => $self->_qterm_to_sqlabstract_like_in( $value, $qterm ) };
        }
    }
    if ( my $trial_id = $query->{'trial_id'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $trial_id, 'patient_id.trial_id' ) };
        push @{ $attrs{ 'join' } }, 'patient_id';
    }
    if ( my $tpoint = $query->{'organ_type'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $tpoint, 'organ_type_id.value' ) };
        push @{ $attrs{ 'join' } }, 'organ_type_id';
    }

    $self->_prepare_query_data_and_detach( $c, \%cond, \%attrs, 'Transplant', $query->{$EXTENDED_FLAG} );
}

=head2 prior_treatments

Canned query method for prior treatments. Available query terms include:

=over 2

=item trial_id

The trial ID for the patient linked to the treatment.

=item id

The internal prior_treatment database ID.

=item type

The type of treatment (e.g. "drug therapy at entry").

=back

=cut

sub prior_treatments : Local {

    my ( $self, $c ) = @_;

    my $query = $self->_decode_json( $c );

    $self->_check_query_terms( $c, $query, [ qw(trial_id id type) ] );

    my ( %cond, %attrs );
    $attrs{ 'join' } = [];
    $cond{ -and }    = [];
    
    foreach my $qterm ( qw(id) ) {
        if ( my $value = $query->{$qterm} ) {
            push @{ $cond{-and} },
                { -or => $self->_qterm_to_sqlabstract_like_in( $value, $qterm ) };
        }
    }
    if ( my $trial_id = $query->{'trial_id'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $trial_id, 'patient_id.trial_id' ) };
        push @{ $attrs{ 'join' } }, 'patient_id';
    }
    if ( my $tpoint = $query->{'type'} ) {
        push @{ $cond{-and} },
            { -or => $self->_qterm_to_sqlabstract_like_in( $tpoint, 'type_id.value' ) };
        push @{ $attrs{ 'join' } }, 'type_id';
    }

    $self->_prepare_query_data_and_detach( $c, \%cond, \%attrs, 'PriorTreatment', $query->{$EXTENDED_FLAG} );
}

###################
# Private methods #
###################

=head1 PRIVATE METHODS

These methods are not accessible to web site users, and are documented
here merely for the benefit of developers.

=cut

sub _decode_json : Private {

    my ( $self, $c ) = @_;

    my $j    = JSON::Any->new;
    my $query;
    eval {
        $query = $j->jsonToObj( $c->request->param( 'data' ) );
    };
    if ( $@ ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Unable to decode JSON request: $@};
        $c->detach( $c->view( 'JSON' ) );
    }

    return $query;
}

sub _check_query_terms : Private {

    my ( $self, $c, $query, $known ) = @_;

    my %okay = map { $_ => 1 } ( @$known, $EXTENDED_FLAG );
    my @missing = grep { ! defined $okay{$_} } keys %$query;
    if ( scalar @missing ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Unknown terms in query: } . join(", ", @missing)
                                   . qq{. Allowed query terms are: } . join(", ", @$known)
                                   . qq{. Allowed flags are: } . $EXTENDED_FLAG;
        $c->detach( $c->view( 'JSON' ) );
    }

    return;
}

sub _qterm_to_sqlabstract_like_in : Private {

    # Return value from this function should be used in a '-or' clause
    # in the main SQL::Abstract hashref.
    my ( $self, $value, $qterm ) = @_;

    if ( ref $value ne 'ARRAY' ) {
        $value = [ $value ];
    }

    # Allow * and ? wildcards, and treat _ and % appropriately.
    foreach my $v ( @$value ) {
        $v =~ s/([_%])/\\$1/g;
        $v =~ tr(*?)(%_);
    }

    return( [ map { $qterm => { -like => $_ } } @$value ] );
}

sub _prepare_query_data_and_detach : Private {

    my ( $self, $c, $cond, $attrs, $class, $dump_rels ) = @_;

    my %methodmap = (
        'Visit'          => '_extract_visit_relationships',
        'Patient'        => '_extract_patient_relationships',
        'Sample'         => '_extract_sample_relationships',
        'Assay'          => '_extract_assay_relationships',
        'PriorTreatment' => '_extract_prior_treatment_relationships',

        # FIXME this will become more important after upcoming additions to the schema.
#        'Transplant'  => '_extract_transplant_relationships',
    );

    my @objs;
    my $rs = $c->model('DB::' . $class);

    my @results;
    eval {
        @results = $rs->search( $cond, $attrs );
    };
    if ( $@ ) {
        $c->stash->{ 'success' } = JSON::Any->false();
        $c->stash->{ 'errorMessage' } = qq{Error in SQL query: $@};
        $c->detach( $c->view( 'JSON' ) );
    }

    foreach my $res ( @results ) {
        my %obj;

        my $cols = $self->_extract_db_columns( $res );
        @obj{ keys %$cols } = values %$cols;

        # This call updates %obj with 1..n and n..n relationships. We
        # only do this when specifically requested as it adds a
        # substantial db query load.
        my $method = $methodmap{ $class };
        if ( defined $method && defined $dump_rels ) {
            $self->$method( $res, \%obj );
        }

        push @objs, \%obj;            
    }
        
    $c->stash->{ 'success' } = JSON::Any->true();
    $c->stash->{ 'data' }    = \@objs;
    $c->detach( $c->view( 'JSON' ) );
}

sub _extract_db_columns : Private {

    my ( $self, $row, $filter ) = @_;

    $filter ||= [];

    my %cols;

    my $source  = $row->result_source();

    COLUMN:
    foreach my $col ( $source->columns() ) {

        # Skip columns which we've been asked to filter out.
        next COLUMN if ( first { $col eq $_ } @$filter );

        my ( $key, $value ) = $self->_extract_column_value( $row, $col );

        $cols{ $key } = $value;
    }

    return \%cols;
}

sub _summarise_relationships : Private {

    my ( $self, $obj, $relationship, $cols ) = @_;

    my @related;
    foreach my $rel ( $obj->$relationship ) {
        my %relhash;
        foreach my $col ( @$cols ) {
            my ( $key, $value ) = $self->_extract_column_value( $rel, $col );
            $relhash{ $key } = $value;
        }

        # This is perhaps a little out of place but it's a convenient spot to do this.
        if ( $relationship eq 'test_results' ) {
            $relhash{ 'value' } = _get_test_value( $rel );
        }

        push @related, \%relhash;
    }

    return \@related;
}

sub _extract_column_value : Private {

    my ( $self, $obj, $col ) = @_;

    my $source  = $obj->result_source();

    my ( $key, $value );
    if ( $source->has_relationship( $col ) ) {
        my $relsource = $source->related_source( $col );
        ( $key ) = ( $col =~ m/(.*)_id/ );

        # Might it be better to set up default stringification methods in the ORM? FIXME.
        if ( $relsource->source_name() eq 'ControlledVocab' ) {
            if ( my $cv = $obj->$col ) {
                $value = $cv->get_column('value');
            }
        }
        elsif ( $relsource->source_name() eq 'PriorGroup' ) {
            if ( my $pg = $obj->$col ) {
                $value = $pg->type_id()->get_column('value') . ': ' . $pg->get_column('name');
            }
        }
        elsif ( $relsource->source_name() eq 'EmergentGroup' ) {
            if ( my $eg = $obj->$col ) {
                $value = $eg->type_id()->get_column('value') . ': ' . $eg->get_column('name');
            }
        }
        elsif ( $relsource->source_name() eq 'Test' ) {
            if ( my $test = $obj->$col ) {
                $value = $test->get_column('name');
            }
        }
        elsif ( $relsource->source_name() eq 'Patient' ) {
            $key = 'trial_id';
            if ( my $test = $obj->$col ) {
                $value = $test->get_column('trial_id');
            }
        }
        elsif ( $relsource->source_name() eq 'Visit' ) {
            $key = 'visit_id';
            if ( my $test = $obj->$col ) {
                $value = $test->get_column('id');
            }
        }
        elsif ( $relsource->source_name() eq 'AssayBatch' ) {
            if ( my $ab = $obj->$col ) {
                $value = $ab->get_column('name') . ' (' . $ab->get_column('date') . ')';
            }
        }
    }
    else {
        $key   = $col;
        $value = $obj->get_column( $col );
    }

    return ( $key, $value );
}

sub _extract_patient_relationships : Private {

    my ( $self, $res, $patient ) = @_;

    # Various relationships (e.g. Visit, Study, AdverseEvents). Note
    # that ideally anything not covered by a full query_* action would
    # be dumped in its entirety here (FIXME). In such cases we don't
    # bother returning the id value. ALSO FIXME consider only
    # returning a subset of these by default, depending on how well
    # these queries perform.
    my %relationship = (
        adverse_events       => [ qw(id type start_date) ],
        clinical_features    => [ qw(type_id) ],
        comorbidities        => [ qw(condition_name date) ],
        diagnoses            => [ qw(id date condition_name_id) ],
        disease_events       => [ qw(type_id start_date) ],
        prior_observations   => [ qw(type_id value date) ],
        patient_prior_groups => [ qw(prior_group_id) ],
        prior_treatments     => [ qw(id type_id value) ],
        risk_factors         => [ qw(type_id) ],
        studies              => [ qw(type_id external_id) ],
        system_involvements  => [ qw(type_id) ],
        transplants          => [ qw(id date organ_type_id) ],
        visits               => [ qw(id date nominal_timepoint_id) ],
    );
    while ( my ( $rel, $cols ) = each %relationship ) {
        $patient->{ $rel } = $self->_summarise_relationships( $res, $rel, $cols );
    }

    return;
}        

sub _extract_visit_relationships : Private {

    my ( $self, $res, $visit ) = @_;

    # See notes for the corresponding patient method.
    my %relationship = (
        drugs                 => [qw(name_id dose dose_unit_id dose_freq_id dose_regime)],
        # test_result value is dealt with in _summarise_relationships.
        test_results          => [qw(test_id date)],
        visit_emergent_groups => [qw(emergent_group_id)],
        samples               => [qw(id name cell_type_id material_type_id)],
        phenotype_quantities  => [qw(type_id value)],
        visit_data_files      => [qw(filename type_id)], 
    );
    while ( my ( $rel, $cols ) = each %relationship ) {
        $visit->{ $rel } = $self->_summarise_relationships( $res, $rel, $cols );
    }
                                        
    return;
}        

sub _extract_sample_relationships : Private {

    my ( $self, $res, $sample ) = @_;

    # See notes for the corresponding patient method.
    my %relationship = (
        assays                 => [qw(filename identifier assay_batch_id)],
        sample_data_files      => [qw(filename type_id)], 
    );
    while ( my ( $rel, $cols ) = each %relationship ) {
        $sample->{ $rel } = $self->_summarise_relationships( $res, $rel, $cols );
    }
                                        
    return;
}        

sub _extract_assay_relationships : Private {

    my ( $self, $res, $assay ) = @_;

    # See notes for the corresponding patient method.
    my %relationship = (
        samples                 => [qw(id name cell_type_id material_type_id)],
        assay_qc_values         => [qw(name type value)],
    );
    while ( my ( $rel, $cols ) = each %relationship ) {
        $assay->{ $rel } = $self->_summarise_relationships( $res, $rel, $cols );
    }
                                        
    return;
}        

sub _extract_prior_treatment_relationships : Private {

    my ( $self, $res, $prior_treatment ) = @_;

    # See notes for the corresponding patient method.
    my %relationship = (
        drugs                 => [qw(name_id dose dose_unit_id dose_freq_id dose_regime)],
    );
    while ( my ( $rel, $cols ) = each %relationship ) {
        $prior_treatment->{ $rel } = $self->_summarise_relationships( $res, $rel, $cols );
    }
                                        
    return;
}        

=head2 dump_assay_entity

Given an Assay object from the database, construct a hashref suitable
for passing back to the user (Private method).

=cut

sub dump_assay_entity : Private {

    my ( $self, $c, $assay, $query ) = @_;

    $query ||= {};

    my $batch = $assay->assay_batch_id();

    my %dump = (
        filename   => $assay->filename(),
        'info.batch.name' => $batch->name(),
        batch_date => $batch->date(),
        identifier => $assay->identifier(),
        operator   => $batch->operator(),
        platform   => $batch->platform_id()->value(),
    );

    my @channels = $assay->channels();

    my @chdata;
    foreach my $ch ( @channels ) {
        push @chdata, {
            label   => $ch->label_id()->value(),
            sample  => $self->dump_sample_entity( $c, $ch->sample_id(), $query ),
        };
    }
    $dump{channels} = \@chdata;

    my %qc_values;
    foreach my $qc ( $assay->assay_qc_values() ) {
        my $name = $qc->name();

        # These characters can screw up any XML output.
        $name =~ s/[ \[\]\/]+/_/g;
        $qc_values{$name} = $qc->value();
    }
    $dump{qc} = \%qc_values;

    return \%dump;
}

=head2 dump_sample_entity

Given a Sample object from the database, construct a hashref suitable
for passing back to the user (Private method).

=cut

sub dump_sample_entity : Private {

    my ( $self, $c, $sample, $query ) = @_;

    $query ||= {};

    my $visit   = $sample->visit_id();
    my $patient = $visit->patient_id();

    my %dump = (
        sample_name    => $sample->name(),
        patient_number => $patient->trial_id(),
        year_of_birth  => $patient->year_of_birth(),
        entry_date     => $patient->entry_date(),
        visit_date     => $visit->date(),
        material_type  => $sample->material_type_id()->value(),
        cell_type      => $sample->cell_type_id()->value(),
        cell_purity    => $sample->cell_purity(),
        studies        => join(', ', map { $_->type_id()->value() } $patient->studies() ),
    );

    if ( my $tp = $sample->visit_id()->nominal_timepoint_id() ) {
        $dump{time_point} = $tp->value();
    }

    # Just return the most recent diagnosis.
    my @diagnoses = map { $_->condition_name_id()->value() }
        reverse sort { $a->date() cmp $b->date() } $patient->diagnoses();
    $dump{diagnosis} = $diagnoses[0];

    my $cohort = $patient->home_centre_id();
    $dump{cohort} = $cohort ? $cohort->value() : undef;

    my $ethnicity = $patient->ethnicity_id();
    $dump{ethnicity} = $ethnicity ? $ethnicity->value() : undef;

    my $disease_activity = $visit->disease_activity_id();
    $dump{disease_activity} = $disease_activity ? $disease_activity->value() : undef;

    $dump{gender} = $patient->sex();

    my %prior = map { $_->type_id->value() => $_->name() }
                $patient->prior_groups();
    $dump{prior_group} = \%prior;

    my %group = map { $_->type_id->value() => $_->name() }
                $visit->emergent_groups();
    $dump{emergent_group} = \%group;

    my %ptreat = map { $_->type_id->value() => $_->value() }
                 grep { defined $_->value() && $_->value ne q{} }
                 $patient->prior_treatments();
    $dump{prior_treatment} = \%ptreat;
    
    $dump{treatment_escalations} =
        $patient->search_related( 'visits',
                                 { treatment_escalation => 1 } )->count();

    $dump{has_infection} = $visit->has_infection();

    ## Test results; default is now to dump nothing.
    my $test_results = $self->dump_test_results( $c, $visit, $query );

    # We only want those TestResults which have no parents. FIXME is
    # there a better way via SQL::Abstract?
    my %tests = map { $_->test_id->name() => _get_test_value($_) }
                grep { $_->parent_test_results()->count() == 0 }
                @$test_results;
    $dump{test_result} = \%tests;

    my $phenotypes = $self->dump_phenotype_quantities( $c, $visit, $query );

    $dump{phenotype} = { map { $_->type_id()->value() => $_->value() } @$phenotypes };

    my $transplant = $self->dump_transplant_data( $c, $visit, $query );

    $dump{transplant} = $transplant;

    return \%dump;
}

sub dump_test_results : Private {

    my ( $self, $c, $visit, $query ) = @_;

    my ( $q, @test_results );
    if ( $q = $query->{'test_ids'} ) {
        @test_results = $visit->search_related('test_results', {
            test_id => { -in => $q },
        });
    }
    elsif ( $q = $query->{'test_names'} ) {        
        @test_results = $visit->search_related('test_results', {
            'test_id.name' => { -in => $q },
        }, { join => 'test_id' });
    }
    elsif ( $q = $query->{'test_pattern'} ) {
        $q =~ s/([_%])/\\$1/g;
        $q =~ tr/*?/%_/;
        @test_results = $visit->search_related('test_results', {
            'test_id.name' => { -like => $q },
        }, { join => 'test_id' });
    }

    return \@test_results;
}

sub dump_phenotype_quantities : Private {

    my ( $self, $c, $visit, $query ) = @_;

    my ( $q, @phenotypes );
    if ( $q = $query->{'phenotype_ids'} ) {
        @phenotypes = $visit->search_related('phenotype_quantities', {
            type_id => { -in => $q },
        });
    }
    elsif ( $q = $query->{'phenotype_names'} ) {        
        @phenotypes = $visit->search_related('phenotype_quantities', {
            'type_id.value' => { -in => $q },
        }, { join => 'type_id' });
    }
    elsif ( $q = $query->{'phenotype_pattern'} ) {
        $q =~ s/([_%])/\\$1/g;
        $q =~ tr/*?/%_/;
        @phenotypes = $visit->search_related('phenotype_quantities', {
            'type_id.value' => { -like => $q },
        }, { join => 'type_id' });
    }

    return \@phenotypes;
}

sub _date_to_days {

    my ( $self, $date ) = @_;

    my ( $y, $m, $d ) = split /-/, $date;
    
    my $days = Date_to_Days( $y, $m, $d );

    return $days;
}

sub _date_diff : Private {

    my ( $self, $tx, $vdays ) = @_;

    my $d = $self->_date_to_days( $tx->date() );

    return abs( $d - $vdays );
}

sub _find_closest_transplant : Private {

    my ( $self, $visit ) = @_;

    my @tx = $visit->search_related('patient_id')->search_related('transplants');

    return unless scalar @tx;

    my $vdays = $self->_date_to_days( $visit->date() );

    # Schwartzian transform to find the closest transplant (perhaps
    # not ideal, but will do for now).
    my @sorted = map { $_->[0] }
                 sort { $a->[1] cmp $b->[1] }
                 map { [ $_, $self->_date_diff( $_, $vdays ) ] } @tx;

    return $sorted[0];
}

sub dump_transplant_data : Private {

    my ( $self, $c, $visit, $query ) = @_;

    my %transplant;
    if ( $query->{'include_transplant'} ) {
        my $tx = $self->_find_closest_transplant( $visit );

        return \%transplant unless ( $tx );

        %transplant = map { $_ => $tx->$_ }
            qw( number recip_cmv donor_cmv days_delayed_function
                mins_cold_ischaemic hla_mismatch donor_age donor_cause_of_death );

        foreach my $cvkey ( qw( sensitisation_status delayed_graft_function
                                organ_type donor_type reperfusion_quality ) ) {
            my $key_id = $cvkey . '_id';
            $transplant{ $cvkey } = defined $tx->$key_id
                                  ? $tx->$key_id->value()
                                  : undef;
        }
    }

    return \%transplant;
}

sub dump_assay_drugs : Private {

    my ( $self, $c, $assay, $query ) = @_;

    my %dump;
    my @channels = $assay->channels();

    my @chdata;
    foreach my $ch ( @channels ) {
        push @chdata, {
            label   => $ch->label_id()->value(),
            sample  => $ch->sample_id()->name(),
            drugs   => $self->dump_sample_drugs( $c, $ch->sample_id(), $query ),
        };
    }
    $dump{channels} = \@chdata;

    return \%dump;
}

sub dump_sample_drugs : Private {

    my ( $self, $c, $sample, $query ) = @_;

    my @dump;

    # $query keys may contain months_prior, prior_treatment_type,
    # drug_type. Note that drug_type can be used to filter both
    # DrugType and DrugName CVs. Both that filter and any synonym_of
    # or part_of pointers must be resolved recursively (with a check
    # on cycles FIXME).

    my $curr_visit = $sample->visit_id();
    my $patient    = $curr_visit->patient_id();

    my $synonym_of = $c->model('DB::ControlledVocab')->find({
        category => 'CVRelationshipType',
        value    => 'synonym_of',
    }) or die("Error: synonym_of CV is not present in database.");
    my $has_part   = $c->model('DB::ControlledVocab')->find({
        category => 'CVRelationshipType',
        value    => 'has_part',
    }) or die("Error: has_part CV is not present in database.");

    my $drug_rs;
    if ( my $prior_type = $query->{'prior_treatment_type'} ) {

        # Undated prior drug treatments, categorised.
        my $pt_cv = $c->model('DB::ControlledVocab')->find({category => 'TreatmentType',
                                                            value    => $prior_type});

        unless ( $pt_cv ) {
            $c->stash->{ 'success' } = JSON::Any->false();
            $c->stash->{ 'errorMessage' }
                = qq{PriorTreatmentType "$prior_type" not found in database.};
            $c->detach( $c->view( 'JSON' ) );
        }
        $drug_rs = $patient->search_related('prior_treatments', { type_id => $pt_cv->id() })
                           ->search_related('drugs')
                           ->search_related('name_id');
    }
    else {

        # Drug treatments related to documented clinical visits.
        my $vdate        = $curr_visit->date();
        my @date_query   = ( 'date' => { '<' => $vdate } );

        # Limit query to N months prior.
        my $months_prior = $query->{'months_prior'};
        if ( defined $months_prior ) {

            ## Calculate the prior date and add it to @date_query.
            my ( $y, $m, $d ) = ( $vdate =~ m/(\d{4})-(\d{2})-(\d{2})/ );
            my $dt = DateTime->new( year => $y, month => $m, day => $d );
            my $pt = $dt->subtract( months => $months_prior );
            my $prior_date = DateTime::Format::MySQL->format_datetime( $pt );

            push @date_query, ( 'date' => { '>' => $prior_date } );
            @date_query = ( '-and' => [ @date_query ] );
        }
        
        $drug_rs = $patient->search_related('visits', { @date_query })
                           ->search_related('drugs')
                           ->search_related('name_id');
    }

    # Resolve synonym_of and has_part relationships.
    my @drug_cvs;

    my $leaves  = $self->_find_all_related_leaves( $c, $drug_rs, [ $synonym_of->id(), $has_part->id() ] );
    my $leaf_rs = $c->model('DB::ControlledVocab')->search( { id => { 'in' => $leaves } } );
    
    while ( my $cv = $leaf_rs->next() ) { push @drug_cvs, $cv }

    # This is recursive as well; there might be multiple levels of
    # is_a relationships.
    if ( my $drug_type = $query->{'drug_type'} ) {

        # Examine @drug_cvs to find things which match drug_type.
        my $isa = $c->model('DB::ControlledVocab')
                    ->find({ category => 'CVRelationshipType',
                             value    => 'is_a' })
                        or die(qq{Error: is_a CV is not present in database});

        # Also support drug_name here as an option.
        my $start_rs = $c->model('DB::ControlledVocab')
                         ->search({ 'me.category' => [ 'DrugType', 'DrugName' ],
                                    'me.value'    => $drug_type });

        # Recursion here.
        my %wanted = map { $_ => 1 } @{ $self->_find_all_isa_children( $start_rs, $isa->id() ) };

        foreach my $cv ( @drug_cvs ) {
            push @dump, $cv->value() if $wanted{ $cv->id() };
        }
    }
    else {

        # Dump everything.
        @dump = map { $_->value() } @drug_cvs;
    }

    return \@dump;
}

sub _find_all_isa_children : Private {

    ## Recursive function to take a CV ResultSet, the is_a
    ## relationship CV term, and find all linked is_a terms. Typically
    ## called with the output of $c->model()->search();

    ## FIXME this is currently vulnerable to cycles in the ontology.
    my ( $self, $start_rs, $isa_query ) = @_;

    return [] unless $start_rs->count() > 0;

    my %wanted;
    while ( my $cv = $start_rs->next() ) {
        $wanted{ $cv->id() }++;
    }

    my $rs = $start_rs->search_related('related_vocab_target_ids',
                                       { 'related_vocab_target_ids.relationship_id'
                                             => $isa_query })
                      ->search_related('controlled_vocab_id');
    
    my $sub = $self->_find_all_isa_children( $rs, $isa_query );

    foreach my $s ( @$sub ) { $wanted{ $s }++ }

    return [ keys %wanted ];
}

sub _find_all_related_leaves : Private {

    ## Basically this is an almost complementary method to
    ## _find_all_isa_children, scanning up through the ontology DAG
    ## instead of down. It differs, however, in only including leaf
    ## terms in the results. FIXME the same caveats apply, especially
    ## regarding cycles.
    my ( $self, $c, $start_rs, $related_query ) = @_;

    return [] unless $start_rs->count() > 0;

    ## We need to process the records in $start_rs to include them as leaves.
    my %wanted;
    while ( my $cv = $start_rs->next() ) {

        ## Only take leaf terms.
        my $num_targets = $c->model('DB::RelatedVocab')->search({
            controlled_vocab_id => $cv->id(),
            relationship_id     => $related_query
        })->count();
        if ( $num_targets == 0 ) {
            $wanted{ $cv->id() }++;
        }
    }

    my $rs = $start_rs->search_related('related_vocab_controlled_vocab_ids',
                                       { 'related_vocab_controlled_vocab_ids.relationship_id'
                                             => $related_query })
                      ->search_related('target_id');
    
    my $sub = $self->_find_all_related_leaves( $c, $rs, $related_query );

    foreach my $s ( @$sub ) { $wanted{ $s }++ }

    return [ keys %wanted ];
}

sub _get_test_value : Private {

    my ( $result ) = @_;

    my $value = $result->value();
    unless ( defined $value ) {
        $value = $result->controlled_value_id()
               ? $result->controlled_value_id()->value()
               : undef
    }

    return $value;
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2012 by Tim F. Rayner

This library is released under version 3 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable;

1;
