package Biblio::Document::Information::Extraction::Format::PDF::Encoding::FreeType;

use strict;
use warnings;
use Moo;

with qw(Biblio::Document::Information::Extraction::Format::PDF::Encoding);

has font => ( is => 'ro', weaken => 1 );

has encoding => ( is => 'lazy' );

sub _build_encoding {
	my ($self) = @_;
	my $encoding;
	$self->font->foreach_char(sub {
		my ($glyph) = ($_);
		if($glyph) {
			my $char = chr($glyph->char_code);
			push @$encoding, $char;
		}
	});
	$encoding;
}

sub decode_string {
	my ($self, $raw_text) = @_;
	my @chars = split '', $raw_text;
	my $decoded = join '', map {
		$_
	} @chars ;
}


1;

=head1 NAME

Biblio::Document::Information::Extraction::Format::PDF::Encoding::FreeType - stores the encoding for a TrueType font

=cut
