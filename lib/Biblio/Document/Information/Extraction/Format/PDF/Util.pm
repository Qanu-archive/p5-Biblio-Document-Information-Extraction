package Biblio::Document::Information::Extraction::Format::PDF::Util;

use strict;
use warnings;

sub get_font_encoding {
	my ($self, $pdf, $font_object) = @_;
	my $encoding_node = $font_object->{Encoding};
	return $pdf->dereference($encoding_node->{value}) if $encoding_node;
	undef;
}

sub get_font_widths {
	my ($self, $pdf, $font_object) = @_;
	return [ map { $_->{value} }
		@{$pdf->dereference($font_object->{Widths}{value})->{value}{value}} ];
}

sub get_font_descriptor {
	my ($self, $pdf, $font_object) = @_;
	return $pdf->dereference($font_object->{FontDescriptor}{value});
}

sub get_font_firstchar {
	my ($self, $pdf, $font_object) = @_;
	return $font_object->{FirstChar}{value};
}

sub get_font_lastchar {
	my ($self, $pdf, $font_object) = @_;
	return $font_object->{LastChar}{value};
}

sub get_font_fontfile_data {
	my ($self, $pdf, $font_object) = @_;
	my $fontfile_objnum;
	my $fd = $self->get_font_descriptor($pdf, $font_object);
	my $fontfile_key;
	for my $key (qw/FontFile FontFile2 FontFile3/) {
		if(exists $fd->{value}{value}{$key}) {
			$fontfile_objnum = $fd->{value}{value}{$key}{value};
			$fontfile_key = $fontfile_key;
			last;
		}
	}
	my $object_data = $pdf->dereference($fontfile_objnum);
	$pdf->decodeAll($object_data);
	return ($object_data, $fontfile_key);
}

sub get_font_fontfile_data_stream {
	my ($self, $pdf, $font_object) = @_;
	my ($font_data, $fontfile_key) = $self->get_font_fontfile_data($pdf, $font_object);
	$font_data->{value}{value}{StreamData}{value};
}


sub get_font_charset {
	my ($self, $pdf, $font_object) = @_;
	return $self->get_font_descriptor($pdf, $font_object)->{value}{value}{CharSet};
}



1;
