package Biblio::Document::Information::Extraction::Format::PDF::Strategy::DumpText;

use strict;
use warnings;
use Moo;

extends 'Data::Visitor';

with qw(Biblio::Document::Information::Extraction::Format::PDF::Strategy);

has text_parts => ( is => 'rw', default => sub{[]} );

has current_font => ( is => 'rw' );

sub visit_array {
	my ($self, $data) = @_;
	$self->visit($_) for @$data;
}

sub dump_text {
	my ($self) = @_;
	my $str;
	for my $tp (@{$self->text_parts}) {
		my $text = $tp->decoded_text;
		if($text =~ /-$/) {
			$text =~ s/-$//;
		} else {
			$text .= " ";
		}
		$str .= $text;
	}
	$str;
}

sub visit_hash {
	my ($self, $data) = @_;
	my $handled = 0;
	if($data->{type} eq 'op') {
		if($data->{name} eq "Tf") {
			$self->current_font( $self->page->get_font($data->{args}[0]{value}) );
			# TODO see if Tf needs to handle more parameters 
			$handled = 1;
		} elsif($data->{name} eq "Tj") {
			push @{$self->text_parts}, PDF::TextData->new(font => $self->current_font, data => $data);
			$handled = 1;
		} elsif($data->{name} eq "TJ") {
			push @{$self->text_parts}, PDF::TextData->new(font => $self->current_font, data => $data);
			$handled = 1;
		}
	}
	unless($handled) {
		$self->visit($_->{args}) if exists $_->{args};
		$self->visit($_->{value}) if exists $_->{value};
	}
}

sub visit_object {
	my ($self, $data) = @_;
	if( ref $data eq 'CAM::PDF::Node' ) {
		if($data->{type} eq "string") {
			push @{$self->text_parts}, PDF::TextData->new(font => $self->current_font, data => $data);
		}
	}
}

1;
