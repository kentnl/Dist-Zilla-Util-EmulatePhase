use 5.008;    #utf8
use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::EmulatePhase::PrereqCollector;

our $VERSION = '1.000002';

#ABSTRACT: A dummy Dist::Zilla to fake a 'prereq' object on.

# AUTHORITY

use Moose qw( has );
use namespace::autoclean;
use Dist::Zilla::Prereqs;

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::Util::EmulatePhase::PrereqCollector",
    "interface":"class",
    "inherits":"Moose::Object"
}

=end MetaPOD::JSON

=cut

has shadow_zilla => (
  is       => 'ro',
  isa      => 'Ref',
  required => 1,
);

has prereqs => (
  is       => 'ro',
  isa      => 'Dist::Zilla::Prereqs',
  init_arg => undef,
  default  => sub { Dist::Zilla::Prereqs->new },
  handles  => [qw( register_prereqs )],
);

## no critic ( Subroutines::RequireArgUnpacking )

=method find_files

L<< C<Dist::Zilla>'s C<find_files>|Dist::Zilla/find_files >> proxy.

=cut

sub find_files {
  return shift->shadow_zilla->find_files(@_);
}

=method plugins

=cut

sub plugins {
  return [];
}
## no critic ( Subroutines::RequireArgUnpacking, Subroutines::ProhibitUnusedPrivateSubroutines, Subroutines::ProtectPrivateSubs )

=method _share_dir_map

L<< C<Dist::Zilla>'s C<_share_dir_map>|Dist::Zilla/_share_dir_map >> proxy.

B<WARNING>: This method is provided as a temporary workaround and may eventually disappear,
as the behaviour it is wrapping probably shouldn't be done like this.

=cut

my $white_list = [
  [ 'Dist::Zilla::Plugin::MakeMaker',          'Dist::Zilla::Plugin::MakeMaker::register_prereqs' ],
  [ 'Dist::Zilla::Plugin::MakeMaker::Awesome', 'Dist::Zilla::Plugin::MakeMaker::Awesome::register_prereqs' ],
];

sub _is_white_listed {
  my ( undef, $package, $subroutine ) = @_;
  for my $list_rule ( @{$white_list} ) {
    next unless $package->isa( $list_rule->[0] );
    next unless $subroutine eq $list_rule->[1];
    return 1;
  }
  return;
}

sub _share_dir_map {
  my $self    = shift;
  my $package = [ caller 0 ]->[0];
  ## no critic (ProhibitMagicNumbers)
  my $subroutine = [ caller 1 ]->[3];

  if ( $self->_is_white_listed( $package, $subroutine ) ) {
    return $self->shadow_zilla->_share_dir_map(@_);
  }

  my $message = <<'_MSG_';
[Dist::Zilla::Util::EmulatePhase] Call to self->zilla->_share_dir_map should be avoided
 ... and your package/sub ( %s::%s ) is not listed in the WhiteList.
 ... Please try eliminate this call to a private method or request it being whitelisted
_MSG_

  require Carp;
  Carp::croak( sprintf $message, $package, $subroutine );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
