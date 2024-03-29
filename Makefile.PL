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
# $Id$
#
use inc::Module::Install;

# NOTE that you must use full paths if invoking "make catalyst_par"
# with a PERL5LIB variable pointing to any dependencies.

name 'ClinStudy-Web';
all_from 'lib/ClinStudy/Web.pm';

requires 'Catalyst::Runtime'                              => '5.71';
requires 'Catalyst::Plugin::ConfigLoader'                 => '0.20';
requires 'Catalyst::Plugin::Static'                       => '0.11';
requires 'Catalyst::Action::RenderView'                   => '0.08';
requires 'Catalyst::Controller::REST'                     => '0.89';
requires 'Catalyst::Controller::HTML::FormFu'             => '0.06001';
requires 'HTML::FormFu::Model::DBIC'                      => '0.08002';
requires 'HTML::FormFu'                                   => '0.08002';
requires 'Catalyst::Plugin::Session'                      => '0.19';
requires 'Catalyst::Plugin::Session::State::Cookie'       => '0.09';
requires 'Catalyst::Plugin::Session::Store::FastMmap'     => '0.05';
requires 'Catalyst::Plugin::Authentication'               => '0.10007';
requires 'Catalyst::Plugin::Authorization::ACL'           => '0.08';    # NOT 0.09!
requires 'Catalyst::Plugin::Authorization::Roles'         => '0.05';
requires 'Catalyst::Authentication::Store::DBIx::Class'   => '0.104';
requires 'parent'                                         => '0.221';
requires 'Config::YAML'                                   => '1.42';
requires 'Template'                                       => '2.19';
requires 'Digest::SHA1'                                   => '2.11';
requires 'Regexp::Common'                                 => '2.122';
requires 'DBD::mysql'                                     => '4.005';
requires 'DBIx::Class'                                    => '0.08010';
requires 'DBIx::Class::Journal'                           => '0.900200';
requires 'XML::LibXML'                                    => '1.7.0';
requires 'Catalyst::View::TT'                             => '0.34';
requires 'Catalyst::View::JSON'                           => '0.30';
requires 'JSON::Any'                                      => '1.22';
requires 'DateTime'                                       => '0.66';
requires 'DateTime::Format::MySQL'                        => '0.04';
requires 'Spreadsheet::Read'                              => '0.45';

# REST currently serialises via XML::Simple
requires 'XML::Simple'                                    => '2.18';

test_requires 'Test::DBIx::Class' => '0.09';

# Some earlier versions don't seem to play nicely with
# Catalyst::Plugin::Static, leading to broken image links. Only needed
# when running under FastCGI.
recommends 'FCGI' => '0.74';

# These are only required for MAGE-TAB export, a non-essential function.
recommends 'Bio::MAGETAB' => '1.1';
recommends 'LWP::UserAgent';
recommends 'Term::ReadKey';
recommends 'FCGI::ProcManager';

# Classes not included by PAR due to obfuscated linking.
catalyst_par_classes('DBD::mysql');
catalyst_par_classes('Digest::SHA');

# Include core perl modules in the PAR package.
catalyst_par_core();

# Core invocations for the Makefile.
catalyst();

install_script glob('script/*.pl');
install_script glob('util/*clinstudy*.pl');

auto_install;
WriteAll;
