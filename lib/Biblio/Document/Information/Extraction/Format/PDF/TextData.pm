package Biblio::Document::Information::Extraction::Format::PDF::TextData;

use strict;
use warnings;
use Moo;
use List::AllUtils qw(first);

has data => ( is => 'ro' );
has matrix => ( is => 'ro' );
has font => ( is => 'ro' );

has raw_text => ( is => 'lazy' );
has text_with_spaces => ( is => 'lazy' );

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
		return $text;# . "|";
	}
	"";
}

sub _build_text_with_spaces {
	my ($self) = @_;
	my $thresh = -200;
	my $last_str = '';
	if( $self->data->{type} eq 'string' ) {
		$last_str = $self->data->{value};
		return $self->data->{value} . " ";
	} elsif($self->data->{name} =~ /T[jJ]/) {
		my $text;
		my $last_number = $thresh;
		my $first = 1;
		my $array;
		if($self->data->{name} eq 'Tj') {
			$array = $self->data->{args};
		} elsif($self->data->{name} eq 'TJ') {
			$array = (first { $_->{type} eq 'array' } @{$self->data->{args}})->{value};
		}
		for my $tj_string ( @$array ) {
			if($tj_string->{type} eq 'number') {
				$last_number = $tj_string->{value};
			}
			next unless $tj_string->{type} eq 'string';
			#$text .= ( not $first and $last_number <= $thresh ? "[$last_number]" :  "($last_number)" ) . $tj_string->{value};
			#$text .= ( not $first and $last_number <= $thresh ? "[$last_number]" :  "" ) . $tj_string->{value};
			$text .= ( not $first and $last_number <= $thresh ? " " :  "" ) . $tj_string->{value};
			$first = 0;
		}
		return $text;
	}
	"";
}


sub decoded_text {
	my ($self) = @_;
	$self->font->encoding->decode_string($self->text_with_spaces);
	#$self->font->encoding->decode_string($self->raw_text);
}


sub width { }

1;
