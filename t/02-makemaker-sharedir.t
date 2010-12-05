use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal 0.003;

use Dist::Zilla::Util::Test::KENTNL 0.01000510 qw( test_config );
use Dist::Zilla::Util::EmulatePhase qw( -all );

my $zilla;
is( exception {
    $zilla = test_config({
        dist_root => 'corpus/dist/DZT',
        ini => ['Prereqs', 'MetaConfig','MakeMaker' ],
    });
}, undef, 'MakeMaker does\'t cause fail' );

my $prereqs;
is( exception {
        $prereqs = get_prereqs({ zilla => $zilla } );
}, undef, 'Can get prereqs with MakeMaker' );

done_testing;
