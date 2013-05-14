
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Smart matching utilities",
  "dist_author" => [
    "Leon Timmermans <leont\@cpan.org>"
  ],
  "dist_name" => "Smart-Match",
  "dist_version" => "0.006",
  "license" => "perl",
  "module_name" => "Smart::Match",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "List::MoreUtils" => 0,
    "Scalar::Util" => 0,
    "Sub::Exporter::Progressive" => 0,
    "XSLoader" => 0,
    "constant" => 0,
    "if" => 0,
    "overload" => 0,
    "perl" => "5.010001",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Test::More" => "0.88"
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
