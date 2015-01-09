package Biblio::Document::Information::Extraction::Format::PDF::Encoding;

use strict;
use warnings;
use Moo::Role;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF::NameToUnicodeTable' => 'PDF::NameToUnicodeTable';

# TODO move the implementation to a sub-role {{{ 
sub char_to_symbol { }

sub decode_string {
	my ($self, $raw_text) = @_;
	my @chars = split '', $raw_text;
	my $decoded = join '', map {
		PDF::NameToUnicodeTable->get_unicode($self->char_to_symbol($_)) // $_
	} @chars ;
}
# }}}

1;


=head1 NAME

Biblio::Document::Information::Extraction::Format::PDF::Encoding - a role that
is used by classes that implement methods to decode a given text string for a
font

=head1 METHODS

=over 4

=item sub decode_string( $string ) - converts a given PDF string to a UTF-8 string

=item sub char_to_symbol( $char ) - takes a single character and returns the
      corresponding PDF symbol # TODO this should be in a sub-role

=cut
