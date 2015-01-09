package Biblio::Document::Information::Extraction::Format::PDF::Page;


use strict;
use warnings;
use 5.010.1;
use Moo;
use Data::Visitor;
use Data::Visitor::Callback;
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Font::PostScript' => 'PDF::Font::PostScript';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Font::FreeType' => 'PDF::Font::FreeType';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::TextData' => 'PDF::TextData';

has content_tree => ( is => 'rw' );
has pdf => ( is => 'ro', weak => 1 );

has fonts => ( is => 'lazy' );
has page_size => ( is => 'lazy' );
has page_number => ( is => 'ro' );

sub _build_fonts {
	my ($self) = @_;
	[$self->pdf->getFontNames(1)]; 
}

sub _build_page_size {
	my ($self) = @_;
	$self->content_tree->{refs}{mediabox};
}

sub render {
	my ($self, $strategy) = @_;
	$strategy->visit($self->content_tree->{blocks});
}

sub get_font {
	my ($self, $font_refname) = @_;
	my $font_ref = $self->pdf->getFont($self->page_number, $font_refname);
	# TODO : FontFactory? FontForge! :-)
	my ($data, $fontfile_key) = PDF::Util->get_font_fontfile_data_stream($self->pdf, $font_ref);
	for($data) {
		when (/^\Q%!PS-AdobeFont-1.0\E/) { return PDF::Font::PostScript->new( pdf => $self->pdf, font_ref => $font_ref  ); }
		default { return PDF::Font::FreeType->new( pdf => $self->pdf, font_ref => $font_ref  ); }
	}
	#for($font_ref->{Subtype}{value}) {
		#when (/^Type1$/) { return PDF::Font::PostScript->new( pdf => $self->pdf, font_ref => $font_ref  ); }
	#}
}

sub get_text_parts {
	my ($self) = @_;
	my $current_font;
	my $current_matrix;
	my $text_parts;
	my $v = Data::Visitor::Callback->new(
		array => sub {
			my ($visitor, $data) = @_;
			$visitor->visit($_) for @$data;
		},
		hash => sub {
			my ($visitor, $data) = @_;
			my $handled = 0;
			if($data->{type} eq 'op') {
				if($data->{name} eq "Tf") {
					$current_font = $self->get_font($data->{args}[0]{value});
					# TODO see if Tf needs to handle more parameters 
					$handled = 1;
				} elsif($data->{name} eq "Tj") {
					push @$text_parts, PDF::TextData->new(font => $current_font, data => $data);
					$handled = 1;
				} elsif($data->{name} eq "TJ") {
					push @$text_parts, PDF::TextData->new(font => $current_font, data => $data);
					$handled = 1;
				}
			}
			unless($handled) {
				$visitor->visit($_->{args}) if exists $_->{args};
				$visitor->visit($_->{value}) if exists $_->{value};
			}
		},
		'CAM::PDF::Node' => sub {
			my ($visitor, $data) = @_;
			if($data->{type} eq "string") {
				push @$text_parts, PDF::TextData->new(font => $current_font, data => $data);
			}
		}
	);
	$v->visit($self->content_tree->{blocks});
	$text_parts;
}

sub dump_text_fonts {
	my ($self) = @_;
	my $text_parts = [];
	my $current_text_part;
	my $v = Data::Visitor::Callback->new(
		array => sub {
			my ($visitor, $data) = @_;
			$visitor->visit($_) for @$data;
		},
		hash => sub {
			my ($visitor, $data) = @_;
			if($data->{type} eq 'op') {
				if($data->{name} eq "Tf") {
					push @$text_parts, $current_text_part if defined $current_text_part;
					$current_text_part = {};
					$current_text_part->{font} = $data->{args}[0]{value};
				} elsif($data->{name} eq "Tj") {
					for my $tj_string ( @{$data->{args}} ) {
						next unless $tj_string->{type} eq 'string';
						push @{$current_text_part->{text}}, $tj_string->{value};
					}
				}
			}
			$visitor->visit($_->{args}) if exists $_->{args};
			$visitor->visit($_->{value}) if exists $_->{value};
		},
		'CAM::PDF::Node' => sub {
			my ($visitor, $data) = @_;
			if($data->{type} eq "string") {
				#print "$data->{value}\n";
				push @{$current_text_part->{text}}, $data->{value};
			}
		}
	);
	$v->visit($self->content_tree->{blocks});
	push @$text_parts, $current_text_part if defined $current_text_part;
	$text_parts;
}

sub dump_text_fonts_charset_conv {
	my ($self) = @_;
	my $text_parts = $self->dump_text_fonts();
	my $fonts;
	for my $part (@$text_parts) {
		$fonts->{$part->{font}} = 1;
	}
	for my $font (keys $fonts) {
		my $font_objectname = "/" . $font;
		my $font = $self->pdf->dereference($font_objectname, $self->page_number)->{value}{value};
		use DDP; p Biblio::Document::Information::Extraction::Format::PDF::Util->get_font_widths($self->pdf, $font);
		use DDP; print "Font: $font_objectname "
		."(@{[p Biblio::Document::Information::Extraction::Format::PDF::Util->get_font_firstchar($self->pdf,$font)]},"
		."@{[p Biblio::Document::Information::Extraction::Format::PDF::Util->get_font_lastchar($self->pdf,$font)]})\n"
		."@{[p Biblio::Document::Information::Extraction::Format::PDF::Util->get_font_charset($self->pdf, $font)]}\n";
	}
	$text_parts;
}

1;
