#!/usr/bin/perl

use Test::More;

use aliased 'Biblio::Document::Information::Extraction::Format::PDF' => 'PDF';
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Strategy::DumpText' => 'PDF::Strategy::DumpText';

use FindBin qw($Bin);
use File::Spec;
my $fname = File::Spec->catfile($Bin, 'data', 'Nain07-spherical-wavelets.pdf'); my $font_num = "F1";

my $pdf = PDF->new( filename => $fname );

my $page = $pdf->get_page(1);
my $strategy = PDF::Strategy::DumpText->new( page => $page );
$page->render($strategy);

use DDP; p $strategy->dump_text;

