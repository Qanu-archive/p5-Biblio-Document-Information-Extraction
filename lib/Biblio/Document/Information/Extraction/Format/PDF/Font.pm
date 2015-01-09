package Biblio::Document::Information::Extraction::Format::PDF::Font;

use strict;
use warnings;
use Moo::Role;

has pdf => ( is => 'rw', weaken => 1 );

has font_ref => ( is => 'ro' );

has encoding => ( is => 'lazy' );

sub width_of_character { my ($self, $char) = @_; undef }

1;

=head1

Biblio::Document::Information::Extraction::Format::PDF::Font - role used to store font information

=cut
