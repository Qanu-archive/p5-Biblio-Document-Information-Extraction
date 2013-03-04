package Biblio::Document::Information::Extraction;

use strict;
use warnings;

#use Unicode::CaseFold; # or v5.16;
#use Unicode::Normalize;
use Text::Unidecode;
use Regexp::Grammars;
use CAM::PDF;

use Moo;
use utf8::all;
use Encode;
use File::Slurp;

has file => ( is => 'rw' ); # read file into text attr after setting file
after file => sub {
	my ($self, $arg) = @_;
	use DDP; p $arg;
	$self->text(join '', read_file($arg, { binmode => ':utf8' })) if $arg;
};

has text => ( is => 'rw' );

has _unidecode_text => ( is => 'lazy' );

sub _build__unidecode_text {
	my ($self) = @_;
	unidecode($self->text);
}


sub section_match {
	my ($self) = @_;
	return [];
}

=head1 NAME

Biblio::Document::Information::Extraction - TODO

=cut

1;
