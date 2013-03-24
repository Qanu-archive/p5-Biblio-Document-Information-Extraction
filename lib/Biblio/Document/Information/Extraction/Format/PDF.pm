package Biblio::Document::Information::Extraction::Format::PDF;

use strict;
use warnings;
use Moo;
use CAM::PDF;
use aliased 'Biblio::Document::Information::Extraction::Format::PDF::Page' => 'PDF::Page';

has pdf => ( is => 'rw', lazy => 1, builder => '_build_pdf' );

has filename => ( is => 'rw' );

sub get_page {
	my ($self, $page_number) = @_;
	my $page_tree = $self->pdf->getPageContentTree($page_number);
	PDF::Page->new( page_number => $page_number, content_tree => $page_tree, pdf => $self->pdf );
}

sub pages {
	my ($self) = @_;
	$self->pdf->numPages;
}

sub _build_pdf {
	my ($self) = @_;
	return CAM::PDF->new($self->filename);
}

1;
