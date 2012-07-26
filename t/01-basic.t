use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal 0.003;

use Dist::Zilla::Util::Test::KENTNL 0.01000510 qw( test_config );
use Dist::Zilla::Util::EmulatePhase qw( -all );

subtest 'deduplicate tests' => sub {
  my @items;
  for ( 1 .. 10 ) {
    push @items, [ rand() ];
  }
  is_deeply( [ deduplicate( @items[ 1, 1, 2, 2, 3, 3, 4, 4 ] ) ], [ @items[ 1, 2, 3, 4 ] ], 'ref based de-duper works (x1)' );
  is_deeply(
    [ deduplicate( @items[ 1, 2, 3, 4, 4, 3, 2, 1, 1, 2, 3, 4 ] ) ],
    [ @items[ 1, 2, 3, 4 ] ],
    'ref based de-duper works (x2)'
  );
  is_deeply(
    [ deduplicate( reverse @items[ 1, 2, 3, 4, 4, 3, 2, 1, 1, 2, 3, 4 ] ) ],
    [ reverse @items[ 1, 2, 3, 4 ] ],
    'ref based de-duper works (x3)'
  );
};

subtest 'expand_modname tests' => sub {
  is( expand_modname('-MetaProvider'), 'Dist::Zilla::Role::MetaProvider', 'Role Expansion works' );
  is( expand_modname('=PreReqs'),      'Dist::Zilla::Plugin::PreReqs',    'Plugin Expansion works' );
};

subtest 'get_plugins test' => sub {
  my @plugins;
  my $zilla;
  is(
    exception {
      $zilla = test_config(
        {
          dist_root => 'corpus/dist/DZT',
          ini       => [ 'Prereqs', 'MetaConfig' ],
        }
      );
    },
    undef,
    'Fake dist setup works'
  );

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

};

subtest 'get_metadata tests' => sub {
  my @plugins;
  my $zilla;
  my $metadata;

  is(
    exception {
      $zilla = test_config(
        {
          dist_root => 'corpus/dist/DZT',
          ini       => [ 'Prereqs', 'MetaConfig', [ 'MetaResources' => { homepage => 'http://example.org' } ] ],
        }
      );
    },
    undef,
    'Fake dist setup works'
  );
  is(
    exception {
      @plugins = get_plugins(
        {
          zilla => $zilla,
          with  => [qw( -MetaProvider )],
        }
      );
    },
    undef,
    'get_plugins does not fail'
  );
  is(
    exception {
      $metadata = get_metadata( { zilla => $zilla } );
    },
    undef,
    'get_metadata does not fail'
  );
  is( ref $metadata,                          'HASH',               'metadata is a hash' );
  is( ref $metadata->{resources},             'HASH',               'metadata.resources is a hash' );
  is( ref $metadata->{resources}->{homepage}, '',                   'resources.homepage is scalar' );
  is( $metadata->{resources}->{homepage},     'http://example.org', 'resources.homepage is input value' );
};

subtest 'get_prereqs tests' => sub {
  my @plugins;
  my $zilla;
  my $prereqs;

  is(
    exception {
      $zilla = test_config(
        {
          dist_root => 'corpus/dist/DZT',
          ini =>
            [ [ 'Prereqs' => { 'foopackage' => 0 } ], 'MetaConfig', [ 'MetaResources' => { homepage => 'http://example.org' } ] ],
        }
      );
    },
    undef,
    'Fake dist setup works'
  );

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

  is(
    exception {
      $prereqs = get_prereqs( { zilla => $zilla } );
    },
    undef,
    'get_prereqs does not fail'
  );

  isa_ok( $prereqs, 'Dist::Zilla::Prereqs' );

  my $rundeps;

  is(
    exception {
      $rundeps = $prereqs->requirements_for( 'runtime', 'requires' );
    },
    undef,
    'requirements_for runs'
  );

  my $isobj  = ref $rundeps and $rundeps->can('isa');
  my $is_CMR = $rundeps->isa('CPAN::Meta::Requirements');
  my $is_VR  = $rundeps->isa('Version::Requirements');

  ok( ( $is_CMR or $is_VR ), 'ISA CPAN::Meta::Requirements / Version::Requirements' );

  if ( not $is_CMR and $is_VR ) {
    diag "WARNING: You still have the deprecated Version::Requirements, upgrading to CPAN::Meta::Requirements is recommended";
  }

  isa_ok( $rundeps->as_string_hash, 'HASH' );
  ok( defined $rundeps->as_string_hash->{foopackage}, 'foopackage dep exists' );
  is( $rundeps->as_string_hash->{foopackage}, 0, 'foopackage depend is on v 0' );
};
done_testing;
