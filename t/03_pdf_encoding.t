#!/usr/bin/perl

use Test::More;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF' => 'PDF';


#my $fname = "$ENV{HOME}/sw_projects/doc_reader/test_pdf/paren.pdf";
#my $fname = "$ENV{HOME}/sw_projects/doc_reader/test_pdf/fi.pdf"; my $font_num = "F8";
#my $fname = "$ENV{HOME}/sw_projects/doc_reader/test_pdf/quote.pdf";
use FindBin qw($Bin);
use File::Spec;
my $fname = File::Spec->catfile($Bin, 'data', 'Nain07-spherical-wavelets.pdf'); my $font_num = "F1";

my $pdf = PDF->new( filename => $fname );

my $page = $pdf->get_page(1);
#use DDP; p $page->content_tree;
#use DDP; use Data::Dumper; p Dumper($page->content_tree);
#use DDP; p $pdf->pdf;
#use DDP; p $page->fonts;
#use DDP; p $page->get_font($font_num);
my $font_refname = $page->fonts()->[-1];
#$font_refname = $font_num;
my $font = $page->get_font($font_refname);
#use DDP; p $font->font_ref;
#use DDP; p $pdf->pdf->dereference($font->font_ref->{FontDescriptor}{value})->{value}{value};
#use DDP; p $font->font_ref;
#$font->encoding->encoding;
#use DDP; p $font->encoding;

#use DDP; p $font->font;
#use DDP; p $font->font->glyph_from_char_code(ord('Þ'));
#use DDP; p $font->font->glyph_from_char('Þ');
#$font->font->foreach_char(sub {
	#my $s = [ $_->char_code, $_->name ];
	#use DDP; p $s;
#});

my $text_parts = $page->get_text_parts();
#use DDP; p $text_parts->[5];
#use DDP; p $text_parts->[5]->raw_text;
#use DDP; &p([map { [ $_ => ord($_) ] } split '', $text_parts->[5]->raw_text]);
#use DDP; p $text_parts->[5]->decoded_text;

my $i = 0;
for my $tp (@$text_parts) {
	#use DDP; p $tp;
	#use DDP; p $tp->data;
	#use DDP; p $tp->raw_text;
	#use DDP; p $i; $i++;
	use DDP; p $tp->decoded_text;
}

