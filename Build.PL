
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::Find' => '0',
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Smart matching utilities',
  'dist_author' => [
    'Leon Timmermans <leont@cpan.org>'
  ],
  'dist_name' => 'Smart-Match',
  'dist_version' => '0.002',
  'license' => 'perl',
  'module_name' => 'Smart::Match',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Carp' => '0',
    'List::MoreUtils' => '0',
    'Scalar::Util' => '0',
    'Sub::Exporter' => '0',
    'XSLoader' => '0',
    'constant' => '0',
    'overload' => '0',
    'perl' => '5.010001'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
