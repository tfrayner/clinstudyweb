#!/usr/bin/env perl
# 
# Copyright 2010 Tim Rayner, University of Cambridge
# 
# This file is part of ClinStudy::Web.
# 
# ClinStudy::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# ClinStudy::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id: 01app.t 161 2010-09-03 11:57:57Z tfrayner $
#

use strict;
use warnings;
use Test::More;
use File::Copy;

BEGIN {
    $ENV{CLINSTUDY_WEB_CONFIG} = 'clinstudy_web_testing.yml';
    copy('t/pristine_testing.db', 't/testing.db');
};

use ok "Test::WWW::Mechanize::Catalyst" => "ClinStudy::Web";

# Create two 'user agents' to simulate two different users ('test01' & 'test02')
my $ua1 = Test::WWW::Mechanize::Catalyst->new;
my $ua2 = Test::WWW::Mechanize::Catalyst->new;

# Use a simplified for loop to do tests that are common to both users
# Use get_ok() to make sure we can hit the base URL
# Second arg = optional description of test (will be displayed for failed tests)
# Note that in test scripts you send everything to 'http://localhost'
$_->get_ok("http://localhost/", "Check access to base URL") for $ua1, $ua2;

my $main_title = "Welcome to ClinStudyWeb";
my $denied     = "You are not allowed to access this resource";

# Use title_is() to check the contents of the <title>...</title> tags
$_->title_is($main_title, "Check for main page title") for $ua1, $ua2;

# Use content_contains() to match on text in the html body
$_->content_contains("Not logged in.",
    "Check we are NOT logged in") for $ua1, $ua2;

$_->get_ok("http://localhost/patient/list", "Check patient list URL") for $ua1, $ua2;
$_->content_contains($denied,
                     "Check restricted access to patient list") for $ua1, $ua2;

# Log in as each user
# Specify username and password on the URL
$ua1->get_ok("http://localhost/login?login=1&username=testuser&password=testuser",
             "Login 'testuser'");
$ua2->get_ok("http://localhost/login?login=1&username=admin&password=admin",
             "Login 'admin'");

$_->title_is($main_title, "Check for redirect to main page") for $ua1, $ua2;

# Go back to the login page and it should show that we are already logged in
$_->get_ok("http://localhost/login", "Return to '/login'") for $ua1, $ua2;
$_->title_is("Log in", "Check for login page") for $ua1, $ua2;
$_->content_contains("Logged in as ",
    "Check we ARE logged in" ) for $ua1, $ua2;

# 'Click' the 'Logout' link (see also 'text_regex' and 'url_regex' options)
$_->follow_link_ok({ url_regex => qr/ \/logout(?:\/)? \z/xms },
                   "Logout via appropriate URL on page") for $ua1, $ua2;
$_->title_is($main_title, "Check for main title page") for $ua1, $ua2;
$_->content_contains("Not logged in.",
    "Check we are NOT logged in") for $ua1, $ua2;

# Log back in
$ua1->get_ok("http://localhost/login?username=testuser&password=testuser&login=1",
             "Login 'testuser'");
$ua2->get_ok("http://localhost/login?username=admin&password=admin&login=1",
             "Login 'admin'");

# Confirm we can access the patients listing.
$_->get_ok("http://localhost/patient/list", "Check patient list URL now logged in") for $ua1, $ua2;
$_->title_is("Patients", "Check for patient list title") for $ua1, $ua2;
$_->content_contains("List patients by study type", "Confirm we now have access") for $ua1, $ua2;

$_->get_ok("http://localhost/", "Navigate back to main page") for $ua1, $ua2;
$_->title_is($main_title, "Check for main page title") for $ua1, $ua2;

# Make sure the appropriate logout buttons are displayed
$_->content_contains(qq{/logout\">Log out</a>},
    "Both users should have a 'Log out' link") for $ua1, $ua2;

# Check on user listing access.
$ua1->content_lacks("List local database users", "testuser has no link to user listing");
$ua2->content_contains("List local database users", "admin has link to user listing");
$_->get_ok("http://localhost/user/list", "Navigate to user list") for $ua1, $ua2;

# Regular user should be denied.
$ua1->title_is("Access denied", "Check for denial of access");
$ua1->content_contains($denied, "Check that regular users have no access to user list");

# Admin user gets access.
$ua2->title_is("User List", "Check for admin-level user list title");
$ua2->content_contains("Last access date", "Check for admin-level content");

# FIXME could try adding/editing content.

done_testing;

