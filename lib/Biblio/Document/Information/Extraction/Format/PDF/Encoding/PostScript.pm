package Biblio::Document::Information::Extraction::Format::PDF::Encoding::PostScript;

use strict;
use warnings;
use Moo;

with qw(Biblio::Document::Information::Extraction::Format::PDF::Encoding);

has encoding_table => ( is => 'rw' ); # char ord to symbol

sub char_to_symbol {
	my ($self, $char) = @_;
	$self->encoding_table->[ord($char)];
}

1;
