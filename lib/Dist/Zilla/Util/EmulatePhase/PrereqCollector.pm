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

## no critic ( Subroutines::RequireArgUnpacking )
=method _share_dir_map

L<< C<Dist::Zilla>'s C<_share_dir_map>|Dist::Zilla/_share_dir_map >> proxy.

B<WARNING>: This method is provided as a temporary workaround and may eventually disappear,
as the behaviour it is wrapping probably shouldn't be done like this.

=cut
sub _share_dir_map {
  my $self = shift;
  require Carp;
  Carp::carp("[Dist::Zilla::Util::EmulatePhase] Call to \$self->zilla->_share_dir_map should be avoided");
  return $self->shadow_zilla->_share_dir_map( @_ );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
