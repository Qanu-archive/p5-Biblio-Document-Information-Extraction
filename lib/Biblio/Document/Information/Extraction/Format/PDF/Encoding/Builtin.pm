package Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin;

use strict;
use warnings;
use 5.010;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::Expert' => 'PDF::Encoding::Builtin::Expert';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::MacExpert' => 'PDF::Encoding::Builtin::MacExpert';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::MacRoman' => 'PDF::Encoding::Builtin::MacRoman';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::Standard' => 'PDF::Encoding::Builtin::Standard';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::Symbol' => 'PDF::Encoding::Builtin::Symbol';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::WinANSI' => 'PDF::Encoding::Builtin::WinANSI';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Encoding::Builtin::ZapfDingbats' => 'PDF::Encoding::Builtin::ZapfDingbats';

sub new_from_font_ref {
	my ($self, $font_ref) = @_;
	for($font_ref->{Encoding}{value}) {
		when(/^MacRomanEncoding$/)  { return PDF::Encoding::Builtin::MacRoman->new(); }
		when(/^MacExpertEncoding/)  { return PDF::Encoding::Builtin::MacExpert->new(); }
		when(/^WinAnsiEncoding$/)   { return PDF::Encoding::Builtin::WinANSI->new(); }
		when(/^StandardEncoding$/)  { return PDF::Encoding::Builtin::Standard->new(); }
		when(/^ExpertEncoding$/)    { return PDF::Encoding::Builtin::Expert->new(); }
		when(/^PDFDocEncoding$/)    { die "TODO"; }
		default                     { die "Unknown: $font_ref->{Encoding}{value}"; }
		# TODO : ZapfDingbats, Symbol, PDFDocEncoding
		# TODO : check semantics of StandardEncoding
	}
}

1;
