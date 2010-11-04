use strict;
use warnings;

package Dist::Zilla::Util::EmulatePhase::PrereqCollector;
BEGIN {
  $Dist::Zilla::Util::EmulatePhase::PrereqCollector::VERSION = '0.01000100';
}
#ABSTRACT: A dummy Dist::Zilla to fake a 'prereq' object on.

use Moose;
use namespace::autoclean;
use Dist::Zilla::Prereqs;

has prereqs => (
  is => 'ro',
  isa => 'Dist::Zilla::Prereqs',
  init_arg => undef,
  default => sub { Dist::Zilla::Prereqs->new },
  handles => [ qw( register_prereqs )],
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
=pod

=head1 NAME

Dist::Zilla::Util::EmulatePhase::PrereqCollector - A dummy Dist::Zilla to fake a 'prereq' object on.

=head1 VERSION

version 0.01000100

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

