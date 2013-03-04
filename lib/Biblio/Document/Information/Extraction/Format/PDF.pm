package Biblio::Document::Information::Extraction::Format::PDF;

use strict;
use warnings;
use Moo;
use CAM::PDF;

has pdf => ( is => 'rw' , required => 1 );

sub get_page {
	my ($self, $page_number) = @_;
	my $page_tree = $self->pdf->getPageContentTree($page_number);
	Biblio::Document::Information::Extraction::Format::PDF::Page
		->new( content_tree => $page_tree );
}

sub pages {
	my ($self) = @_;
	$self->pdf->numPages;
}

package Biblio::Document::Information::Extraction::Format::PDF::Page;

use Moo;
use Data::Visitor::Callback;

has content_tree => ( is => 'rw' );

has fonts => ( is => 'lazy' );
has page_size => ( is => 'lazy' );

sub _build_fonts {
	my ($self) = @_;
	my $prop = $self->content_tree->{refs}{properties};
	scalar { map { $_ => $prop->{$_} } keys $prop };
}

sub _build_page_size {
	my ($self) = @_;
	$self->content_tree->{refs}{mediabox};
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



1;
