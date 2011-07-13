use strict;
use warnings;

package Dist::Zilla::Util::EmulatePhase::PrereqCollector;
BEGIN {
  $Dist::Zilla::Util::EmulatePhase::PrereqCollector::VERSION = '0.01025800';
}

#ABSTRACT: A dummy Dist::Zilla to fake a 'prereq' object on.

use Moose;
use namespace::autoclean;
use Dist::Zilla::Prereqs;

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


sub find_files {
  return shift->shadow_zilla->find_files(@_);
}

## no critic ( Subroutines::RequireArgUnpacking, Subroutines::ProhibitUnusedPrivateSubroutines, Subroutines::ProtectPrivateSubs )


my $white_list = [ [ 'Dist::Zilla::Plugin::MakeMaker', 'Dist::Zilla::Plugin::MakeMaker::register_prereqs' ] ];

sub _is_white_listed {
  my ( $self, $package, $subroutine ) = @_;
  for my $list_rule ( @{$white_list} ) {
    next unless $package->isa( $list_rule->[0] );
    next unless $subroutine eq $list_rule->[1];
    return 1;
  }
  return;
}

sub _share_dir_map {
  my $self       = shift;
  my $package    = [ caller 0 ]->[0];
  ## no critic (ProhibitMagicNumbers)
  my $subroutine = [ caller 1 ]->[3];

  if ( $self->_is_white_listed( $package, $subroutine ) ) {
    return $self->shadow_zilla->_share_dir_map(@_);
  }

  require Carp;
  Carp::croak( "[Dist::Zilla::Util::EmulatePhase] Call to self->zilla->_share_dir_map should be avoided\n"
      . "  ... and your package/sub ( $package :: $subroutine ) is not listed in the WhiteList\n"
      . "  ... Please try eliminate this call to a private method or request it being whitelisted\n" );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__
=pod

=head1 NAME

Dist::Zilla::Util::EmulatePhase::PrereqCollector - A dummy Dist::Zilla to fake a 'prereq' object on.

=head1 VERSION

version 0.01025800

=head1 METHODS

=head2 find_files

L<< C<Dist::Zilla>'s C<find_files>|Dist::Zilla/find_files >> proxy.

=head2 _share_dir_map

L<< C<Dist::Zilla>'s C<_share_dir_map>|Dist::Zilla/_share_dir_map >> proxy.

B<WARNING>: This method is provided as a temporary workaround and may eventually disappear,
as the behaviour it is wrapping probably shouldn't be done like this.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

