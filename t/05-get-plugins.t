
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal 0.003;
use Test::DZil qw( simple_ini );
use Dist::Zilla::Util::Test::KENTNL 1.002000 qw( dztest );
use Dist::Zilla::Util::EmulatePhase qw( -all );

# ABSTRACT: Test get_plugins
my $test = dztest();
$test->add_file( 'dist.ini', simple_ini( 'Prereqs', 'MetaConfig' ) );
$test->build_ok;
my $zilla = $test->builder;
my @plugins;
subtest 'with tests' => sub {
  is(
    exception {
      @plugins = get_plugins(
        {
          zilla => $zilla,
          with  => [qw( -PrereqSource )],
        }
      );
    },
    undef,
    'get_plugins does not fail'
  );

  is( scalar @plugins, 1, "Only 1 plugin found" );
  isa_ok( $plugins[0], 'Dist::Zilla::Plugin::Prereqs' );
};

subtest 'skip_with tests' => sub {
  is(
    exception {
      @plugins = get_plugins(
        {
          zilla     => $zilla,
          with      => [qw( -Plugin )],
          skip_with => [qw( -PrereqSource )],
        }
      );
    },
    undef,
    'get_plugins does not fail'
  );
  my $nomatch = undef;
  for (@plugins) {
    $nomatch = $_ if $_->isa('Dist::Zilla::Plugin::Prereqs');
  }
  is( $nomatch, undef, 'Filtered -does stuff goes away' );
};

subtest 'straight skip_isa tests' => sub {
  is(
    exception {
      @plugins = get_plugins(
        {
          zilla    => $zilla,
          skip_isa => [qw( =Prereqs )],
        }
      );
    },
    undef,
    'get_plugins does not fail'
  );
  my $nomatch = undef;
  for (@plugins) {
    $nomatch = $_ if $_->isa('Dist::Zilla::Plugin::Prereqs');
  }
  is( $nomatch, undef, 'Filtered -does stuff goes away' );
};

done_testing;

