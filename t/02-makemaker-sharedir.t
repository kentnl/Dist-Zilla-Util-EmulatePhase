use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal 0.003;

use Test::DZil qw( simple_ini );
use Dist::Zilla::Util::Test::KENTNL 1.002000 qw( dztest );
use Dist::Zilla::Util::EmulatePhase qw( -all );

my $test = dztest();
$test->add_file( 'dist.ini', simple_ini( 'Prereqs', 'MetaConfig', 'MakeMaker' ) );
$test->build_ok;
my $zilla = $test->builder;
my $prereqs;
is(
  exception {
    $prereqs = get_prereqs( { zilla => $zilla } );
  },
  undef,
  'Can get prereqs with MakeMaker'
);

done_testing;
