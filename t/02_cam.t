#!/usr/bin/perl

use Test::More;

use FindBin qw($Bin);
use File::Spec;

use CAM::PDF;
use Data::Visitor::Callback;
use utf8::all;
use Set::Scalar;

use Data::Printer {  class => { expand => 'all' } };

my $fname = File::Spec->catfile($Bin, 'data', 'Nain07-spherical-wavelets.pdf');
my $pdf = CAM::PDF->new($fname);
my $page_number = 1;
#my $page_number = $pdf->numPages;

use Biblio::Document::Information::Extraction::Format::PDF;

#cam_getfonts();
#pdf_object();
test_encoding_pdf();
#test_backslash_parse();

sub test_backslash_parse {
	#my $str = '[(\050\134\051)]TJ';
	#my $str = '[(a\134b)]TJ';
	#my $str = '[(a\\\\b)]TJ';
	for my $str (q{(\134)}, q{(\\\\)}) {
		is( CAM::PDF->parseAny(\$str)->{value}, '\\' , "parsing: $str");
	}
	my $str = '(a\n\134'.'\\\\'.'\nb)';
	is( CAM::PDF->parseAny(\$str)->{value}, "a\n\\\\\nb" , "parsing: $str");
		#use DDP; p $str;
		#my $node = CAM::PDF->parseAny(\$str);
		#use DDP; p($node);
	#use DDP; &p([length $node->{value}[0]{value}]);
	
}



sub test_encoding_pdf {
	my $fname = "$ENV{HOME}/sw_projects/doc_reader/test_pdf/fi.pdf";
	#my $fname = "$ENV{HOME}/sw_projects/doc_reader/test_pdf/quote.pdf";
	#my $fname = "$ENV{HOME}/sw_projects/doc_reader/test_pdf/paren.pdf";
	my $pdf = CAM::PDF->new($fname);
	my $o = Biblio::Document::Information::Extraction::Format::PDF->new( pdf => $pdf );
	use DDP; p $o->get_page(1)->content_tree;
	use DDP; p $o->get_page(1)->dump_text_fonts;
	#my $font = $o->pdf->dereference("/F8", 1);
	#use DDP; p $font;
	for my $str ( @{$o->get_page(1)->dump_text_fonts()->[0]{text}} ) {
		print $str, " : ", length($str), "\n";
	}
#
	#use DDP; p $o->pdf->dereference($font->{value}{value}{FontDescriptor}{value});
}

sub pdf_object {
	my $fname = File::Spec->catfile($Bin, 'data', 'Nain07-spherical-wavelets.pdf');
	my $pdf = CAM::PDF->new($fname);
	my $o = Biblio::Document::Information::Extraction::Format::PDF->new( pdf => $pdf );
	#my $p = $o->get_page( 8 );
		#use DDP; p $p->page_size;
	for my $page_no ( 21 ) {
		# ( 1 .. $o->pages ) {
		my $p = $o->get_page($page_no);
		use DDP; p $p->content_tree;
		use DDP; p $p->dump_text_fonts;
		use DDP; p $o->pdf->dereference("/F1", 1);
		use DDP; p $o->pdf->dereference("/F4", 1);
	}
	use DDP; &p([$o->pdf->getPropertyNames(21)]);
}


sub font_stuff {
=for oldcode
	my $properties = [ $pdf->getPropertyNames(1) ];
		#use DDP; p $properties;
	#use DDP; p $pdf->getProperty(1,"F1" );
	#use DDP; p $pdf->dereference("/F1", 1)->{value}->{value};
	#use DDP; p $pdf->dereference("/F2", 1)->{value}->{value};
	#return;
	my $fonts = $p->fonts;
		use DDP; p $fonts;
	my $font_objnum_font;
		push @{$font_objnum_font->{$fonts->{$_}{objnum}}}, $_ for keys $fonts;
		use DDP; p $font_objnum_font;
		for my $objnum (keys $font_objnum_font) {
			my $font_dict = $pdf->{objcache}{$objnum}{value};
			use DDP; p $font_dict->{value}{Font};
			use DDP; p $font_dict->{value}{Font}{value}{F1};
		}
		use DDP; p $pdf->{objcache};
=cut
}

sub cam_getfonts {
	use DDP; p $pdf->getFontNames($pagenum);
}

sub cam_renderertext {
	my $contentTree = $pdf->getPageContentTree($page_number);
	print($contentTree->render("CAM::PDF::Renderer::Text")->toString);
}

sub cam_rendererdump {
	my $contentTree = $pdf->getPageContentTree($page_number);
	$contentTree->render("CAM::PDF::Renderer::Dump");
}

sub cam_tranversecontenttree {
	my $pagetree = $pdf->getPageContentTree($page_number);
	my @stack = ([@{$pagetree->{blocks}}]);
	my $object_types = Set::Scalar->new();
	my $name_types = Set::Scalar->new();
	my $v = Data::Visitor::Callback->new(
		array => sub {
			my ($visitor, $data) = @_;
			$visitor->visit($_) for @$data;
		},
		hash => sub {
			my ($visitor, $data) = @_;
			$object_types->insert( lc $data->{type} ) if exists $data->{type};
			$name_types->insert( lc $data->{name} ) if exists $data->{name};
			#use DDP; p $data;
			#if(exists $data->{type} and $data->{type} eq 'op' and "\L$data->{name}" eq "\LTJ") {
				#print "$data->{name}\n";
				##push @column_defs_cols, $data->{value} if exists $data->{value};
				##$visitor->visit($_) for values $data; # recurse
				#$visitor->visit($_->{value}) for values $data->{args}; # recurse
			#} else {
				#$visitor->visit($_) for $data->{args}; # recurse
			#}
			$visitor->visit($_->{args});
			$visitor->visit($_->{value});
		},
		'CAM::PDF::Node' => sub {
			my ($visitor, $data) = @_;
			if($data->{type} eq "string") {
				print "$data->{value}\n";
			}
		}
	);
	use DDP; p $pagetree;
	$v->visit($pagetree->{blocks});
	print "$object_types\n";
	print "$name_types\n";
	#use DDP; p $pagetree->{blocks};
}

sub cam_getpagetext {
	my $str = $pdf->getPageText($page_number);
	if (defined $str) {
		CAM::PDF->asciify(\$str);
		print $str;
	}
}

done_testing;
