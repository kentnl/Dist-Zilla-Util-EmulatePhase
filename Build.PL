
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4007"
  },
  "configure_requires" => {
    "Module::Build" => "0.4007"
  },
  "dist_abstract" => "Nasty tools for probing L<< C<Dist::Zilla>'s|Dist::Zilla >> internal state.",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-Util-EmulatePhase",
  "dist_version" => "0.01025803",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Util::EmulatePhase",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "Dist::Zilla::Prereqs" => 0,
    "Hash::Merge::Simple" => 0,
    "Moose" => 0,
    "Moose::Autobox" => 0,
    "Scalar::Util" => 0,
    "Sub::Exporter" => 0,
    "Try::Tiny" => 0,
    "namespace::autoclean" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Dist::Zilla::Util::Test::KENTNL" => "0.01000510",
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::Fatal" => "0.003",
    "Test::More" => "0.99"
  }
);


my %fallback_build_requires = (
  "Dist::Zilla::Util::Test::KENTNL" => "0.01000510",
  "File::Spec" => 0,
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "Module::Build" => "0.4007",
  "Test::Fatal" => "0.003",
  "Test::More" => "0.99"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
