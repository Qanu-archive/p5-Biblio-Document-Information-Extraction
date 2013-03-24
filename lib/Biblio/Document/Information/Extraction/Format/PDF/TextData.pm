package Biblio::Document::Information::Extraction::Format::PDF::TextData;

use strict;
use warnings;
use Moo;
use List::AllUtils qw(first);

has data => ( is => 'ro' );
has matrix => ( is => 'ro' );
has font => ( is => 'ro' );

has raw_text => ( is => 'lazy' );

sub _build_raw_text {
	my ($self) = @_;
	if( $self->data->{type} eq 'string' ) {
		return $self->data->{value};
	} elsif($self->data->{name} eq 'Tj') {
		my $text;
		for my $tj_string ( @{$self->data->{args}} ) {
			next unless $tj_string->{type} eq 'string';
			$text .= $tj_string->{value};
		}
		return $text;
	} elsif($self->data->{name} eq 'TJ') {
		my $text;
		for my $tj_string ( @{
			(first { $_->{type} eq 'array' } @{$self->data->{args}})->{value}
			} ) {
			next unless $tj_string->{type} eq 'string';
			$text .= $tj_string->{value};
		}
		return $text;
	}
	"";
}

sub decoded_text {
	my ($self) = @_;
	$self->font->encoding->decode_string($self->raw_text);
}


sub width { }

1;
