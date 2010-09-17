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

BEGIN {
    $ENV{CLINSTUDY_WEB_CONFIG} = 'clinstudy_web_testing.yml';
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

# Use title_is() to check the contents of the <title>...</title> tags
$_->title_is($main_title, "Check for main page title") for $ua1, $ua2;

# Use content_contains() to match on text in the html body
$_->content_contains("Not logged in.",
    "Check we are NOT logged in") for $ua1, $ua2;

$_->get_ok("http://localhost/patient/list", "Check patient list URL") for $ua1, $ua2;
$_->content_contains("You are not allowed to access this resource",
                     "Check restricted access to patient list") for $ua1, $ua2;

# Log in as each user
# Specify username and password on the URL
$ua1->get_ok("http://localhost/login?login=1&username=testuser&password=testuser",
             "Login 'testuser'");
$ua2->get_ok("http://localhost/login?login=1&username=testeditor&password=testeditor",
             "Login 'testeditor'");

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
$ua2->get_ok("http://localhost/login?username=testeditor&password=testeditor&login=1",
             "Login 'testeditor'");

# Confirm we can access the patients listing.
$_->get_ok("http://localhost/patient/list", "Check patient list URL now logged in") for $ua1, $ua2;
$_->title_is("Patients", "Check for patient list title") for $ua1, $ua2;

die;

$ua1->get_ok("http://localhost/books/list", "'test01' book list");
$ua1->get_ok("http://localhost/login", "Login Page");
$ua1->get_ok("http://localhost/books/list", "'test01' book list");

$_->content_contains("Book List", "Check for book list title") for $ua1, $ua2;

# Make sure the appropriate logout buttons are displayed
$_->content_contains("/logout\">User Logout</a>",
    "Both users should have a 'User Logout'") for $ua1, $ua2;
$ua1->content_contains("/books/form_create\">Admin Create</a>",
    "'test01' should have a create link");
$ua2->content_lacks("/books/form_create\">Admin Create</a>",
    "'test02' should NOT have a create link");

$ua1->get_ok("http://localhost/books/list", "View book list as 'test01'");

# User 'test01' should be able to create a book with the "formless create" URL
$ua1->get_ok("http://localhost/books/url_create/TestTitle/2/4",
    "'test01' formless create");
$ua1->title_is("Book Created", "Book created title");
$ua1->content_contains("Added book 'TestTitle'", "Check title added OK");
$ua1->content_contains("by 'Stevens'", "Check author added OK");
$ua1->content_contains("with a rating of 2.", "Check rating added");

# Try a regular expression to combine the previous 3 checks & account for whitespace
$ua1->content_like(qr/Added book 'TestTitle'\s+by 'Stevens'\s+with a rating of 2./, "Regex check");

# Make sure the new book shows in the list
$ua1->get_ok("http://localhost/books/list", "'test01' book list");
$ua1->title_is("Book List", "Check logged in and at book list");
$ua1->content_contains("Book List", "Book List page test");
$ua1->content_contains("TestTitle", "Look for 'TestTitle'");

# Make sure the new book can be deleted
# Get all the Delete links on the list page
my @delLinks = $ua1->find_all_links(text => 'Delete');

# Use the final link to delete the last book
$ua1->get_ok($delLinks[$#delLinks]->url, 'Delete last book');

# Check that delete worked
$ua1->content_contains("Book List", "Book List page test");
$ua1->content_contains("Book deleted", "Book was deleted");

# User 'test02' should not be able to add a book
$ua2->get_ok("http://localhost/books/url_create/TestTitle2/2/5", "'test02' add");
$ua2->content_contains("Unauthorized!", "Check 'test02' cannot add");

done_testing;

