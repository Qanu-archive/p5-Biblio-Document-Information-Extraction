package Biblio::Document::Information::Extraction::Format::PDF::Font::FreeType;

use strict;
use warnings;
use Moo;
use Font::FreeType;
use File::Slurp qw/write_file/;
use File::Temp;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::FreeType' => 'PDF::Encoding::FreeType';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Util' => 'PDF::Util';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin' => 'PDF::Encoding::Builtin';

with qw(Biblio::Document::Information::Extraction::Format::PDF::Font);

has font => ( is => 'lazy' );

sub _build_encoding {
	my ($self) = @_;
	#return PDF::Encoding::FreeType->new(font => $self->font);
	return PDF::Encoding::Builtin->new_from_font_ref($self->font_ref);
}

sub _build_font {
	my ($self) = @_;
	my $data = PDF::Util->get_font_fontfile_data_stream($self->pdf, $self->font_ref);
	my $fh = File::Temp->new;
	write_file($fh->filename, $data);
	my $freetype = Font::FreeType->new;
	my $font = $freetype->face($fh->filename);
	return $font;
}


1;
