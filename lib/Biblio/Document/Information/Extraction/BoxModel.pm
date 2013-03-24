package Biblio::Document::Information::Extraction::BoxModel;

use strict;
use warnings;
use Moo;

has page_x => ( is => 'rw', default => sub { 0 } );
has page_y => ( is => 'rw', default => sub { 0 } );

has page_width => ( is => 'rw', default => sub { 0 } );
has page_height => ( is => 'rw', default => sub { 0 } );


1;
