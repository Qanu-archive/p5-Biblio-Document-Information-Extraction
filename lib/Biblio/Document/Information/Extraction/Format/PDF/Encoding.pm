package Biblio::Document::Information::Extraction::Format::PDF::Encoding;

use strict;
use warnings;
use Moo::Role;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF::NameToUnicodeTable' => 'PDF::NameToUnicodeTable';

sub decode_string {
	my ($self, $raw_text) = @_;
	my @chars = split '', $raw_text;
	my $decoded = join '', map {
		PDF::NameToUnicodeTable->get_unicode($self->char_to_symbol($_)) // $_
	} @chars ;
}


1;
