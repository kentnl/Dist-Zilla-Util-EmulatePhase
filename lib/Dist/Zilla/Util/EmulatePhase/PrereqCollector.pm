use strict;
use warnings;

package Dist::Zilla::Util::EmulatePhase::PrereqCollector;
#ABSTRACT: A dummy Dist::Zilla to fake a 'prereq' object on.

use Moose;
use namespace::autoclean;
use Dist::Zilla::Prereqs;

has shadow_zilla => (
  is => 'ro',
  isa => 'Ref',
  required => 1,
);

has prereqs => (
  is => 'ro',
  isa => 'Dist::Zilla::Prereqs',
  init_arg => undef,
  default => sub { Dist::Zilla::Prereqs->new },
  handles => [ qw( register_prereqs )],
);

## no critic ( Subroutines::RequireArgUnpacking )
=method find_files

L<< C<Dist::Zilla>'s C<find_files>|Dist::Zilla/find_files >> proxy.

=cut
sub find_files {
  return shift->shadow_zilla->find_files( @_ );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;