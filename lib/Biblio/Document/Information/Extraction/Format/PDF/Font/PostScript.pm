package Biblio::Document::Information::Extraction::Format::PDF::Font::PostScript;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::PostScript' => 'PDF::Encoding::PostScript';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Util' => 'PDF::Util';

use strict;
use warnings;
use Moo;
use PostScript::Font;

use File::Slurp qw/write_file/;
use File::Temp;

with qw(Biblio::Document::Information::Extraction::Format::PDF::Font);


sub _build_encoding {
	my ($self) = @_;
	return PDF::Encoding::PostScript->new( encoding_table => $self->_get_encoding_table() );
}

sub _get_encoding_table {
	my ($self) = @_;
	my $data = PDF::Util->get_font_fontfile_data_stream($self->pdf, $self->font_ref);
	my $fh = File::Temp->new;
	write_file($fh->filename, $data);
	my $font = PostScript::Font->new( $fh->filename );
	$fh = undef; # unlink_on_destroy
	return $font->Encoding;
}

1;

=head1

Biblio::Document::Information::Extraction::Format::PDF::Font::PostScript - load a PostScript font

=cut
