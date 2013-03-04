#!/usr/bin/perl

use Test::More;

use FindBin qw($Bin);
use File::Spec;

BEGIN { use_ok( 'Biblio::Document::Information::Extraction' ); }
require_ok( 'Biblio::Document::Information::Extraction' );

my $fname = File::Spec->catfile($Bin, 'data', 'Nain07-spherical-wavelets.txt');
#my $fname = File::Spec->catfile($Bin, 'data', 'nain-miccai05.txt');


ok( my $bib = Biblio::Document::Information::Extraction->new(), 'new extractor');
$bib->file($fname);

#use DDP; p $bib->_unidecode_text;
#my $match = [$bib->_unidecode_text =~ //g];
#use DDP; p $match;
my $page_pos = [ 0 ]; # first page at beginning of file
my $page_text = $bib->_unidecode_text;
push $page_pos, pos($page_text) - length($+{ALL}) while($page_text =~ /(?<ALL>\f)/g);
my $fence_page_pos = [@$page_pos]; # contains 0, p1, p2, 'end'
pop $page_pos; # last \f is the end of the last page (removes 'end')

my $num_pages = scalar @$page_pos;
print STDERR "There are $num_pages pages\n";

my $headers = {};
my $text = $bib->_unidecode_text;

#use DDP; p $text;
while( $text =~ /(?<ALL>(?<PRE>^|\n)(?<BACK>(?<text>[^\n]+)(?<POST>\n|$)))/sg ) {
	$headers->{$+{text}}{count}++;
	push @{$headers->{$+{text}}{pos}}, pos($text) - length($+{BACK});
}


use Scalar::Util qw/looks_like_number/;
use List::Util qw/sum/;
use List::MoreUtils qw/any/;

my $numbers_to_header = {};
push @{$numbers_to_header->{0+$_}}, $_
	for grep { looks_like_number($_) } keys $headers;
my $numbers_para = [ sort { $a <=> $b } keys $numbers_to_header ];

my $page_labels;
if( $num_pages <= @$numbers_para ) {
	my $offsets = @$numbers_para - $num_pages;
	for my $offset (0..$offsets) {
		my $num_slice = [@$numbers_para[$offset..$offset+$num_pages-1]];
		if( List::Util::sum( map { $num_slice->[$_]+1 == $num_slice->[$_+1] }
				0..@$num_slice-2) == $num_pages-1 ) {
			# if each page is consecutive
			my $all_pages = 1; # if all page labels are on their corresponding pages
			for my $cur_page (0..$num_pages-1) {
				my $num_slice_pos;
				push @$num_slice_pos, @{$headers->{$_}{pos}}
					for(@{$numbers_to_header->{$num_slice->[$cur_page]}});
				#print STDERR "$fence_page_pos->[$cur_page] : (@$num_slice_pos) : $fence_page_pos->[$cur_page+1]\n";
				$all_pages &&=  any { $fence_page_pos->[$cur_page] <= $_
					&& $_ <= $fence_page_pos->[$cur_page+1] } @$num_slice_pos; 
				break unless $all_pages;
			}
			# if each element of num_slice exists on corresponding page
			if( $all_pages ) {
				$page_labels = $num_slice;
				break;
			}
		}
	}
}
print STDERR "The page numbers are probably: $page_labels->[0]..$page_labels->[-1]\n" if $page_labels;




#use DDP; &p({ map { $_ => $headers->{$_}{count} } grep { $headers->{$_}{count} > 1 } keys $headers });
#my $keys = [ sort { $headers->{$b}{count} <=> $headers->{$a}{count} } grep { $headers->{$_}{count} > 1 } keys $headers ];
#use DDP; p $keys;

my $header_foot_count_min = ($num_pages - 1) / 2 - 1;
my $header_foot_char_min = 5;
my $possible_headers =  [ map { $_ =~ s,\f\n,,gr }
	grep { length($_) > $header_foot_char_min
		&& $headers->{$_}{count} > $header_foot_count_min }
	keys $headers ];
use DDP; p $possible_headers;

my $deheader_text = $bib->_unidecode_text;
$deheader_text =~ s,\Q$_\E,,g for @$possible_headers;
#use DDP; p $deheader_text;

my $references_sec = ($deheader_text =~ /^REFERENCES(.*\z)/smg )[0];
$references_sec =~ s,^\f?\d+$,,smg;
#use DDP; p $references_sec;

use Regexp::Grammars;
my $reflist_parser = qr{
    <nocontext:>
    #REFERENCES \s+
    <[Citation]>+ \z

    <token: LeftBrace>      [ \( \[ ]
    <token: RightBrace>     [ \) \] ]
    <token: CiteKey>        \d+ | \w+(?:\d{2}|\d{4})
    <token: CiteBody>             .+?

    <rule: CiteStart> ^ <.LeftBrace> <MATCH=CiteKey> <.RightBrace>
    <rule: Citation> <CiteKey= CiteStart>  (?! <.CiteStart> ) <CiteBody>
}xms;
my $cite_parser = qr{
    <nocontext:>
    #<debug: match>
    \A <CiteBody> \Z

    <rule: CiteBody>
	    <Online> | <Article> | <Proceeding> | <InBook> | <InConference> | <Book>

    <rule: Article>
	    <Authors> ,
	    " <Title= (.+?)> , "
	    <Journal= (.+?)> ,
	    (<Volume> ,)? (<Number> ,)? <Pages> , <When> \.?

    <rule: Proceeding>
	    <Authors> ,
	    " <Title= (.+?)> , "
	    in <Proceeding= (Proc .+?)> ,
	    (<Location = (.+?)> ,)?
	    <When> ,
	    (<Volume> ,)?
	    (<Series= (.+?)> ,)?
	    <Pages> \.?

    <rule: Online> 
	    <Title= ([^,]+?)>? ,
	    <Source= (.+?)>
	    \[ Online \] \.?
	    Available : <URL= (.+?)>
	    \.?

    <rule: Book>
	    <Authors> ,
	    <Book= (.+?)> \.
	    <Location = (.+?)> : <Press= (.+?)> ,
	    <When> \.?

    <rule: InBook>
	    <Authors> ,
	    " <Title= (.+?)> , "
	    in <Book= (.+?)> \.
	    <Location = (.+?)> : <Press= (.+?)> ,
	    <When>, (<Volume> ,)? <Pages> \.?

    <rule: InConference>
	    <Authors> ,
	    " <Title= (.+?)> , "
	    in <Conference= (.+?)> \.
	    <When>, (<Volume> ,)? <Pages> \.?


    <rule: Volume>  vol \.? <MATCH= (\d+)>
    <rule: Number>  no \.? <MATCH= (\d+)>
    <rule: Pages> (pp?\.?)? <MATCH= PageSpec>
    <rule: Year> \d{2} | \d{4}
    <rule: Month> Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec
    <rule: When> (<Month>\.?)? <Year>
    <rule: PageSpec>   <FirstPage= (\d+)> ( - <LastPage= (\d+)> )?

    #<token: ListSep>        [ , ]
    <rule: AuthorPart>     [A-Z][\w.-]+? # let's just assume first character is uppercase for now: no e.e. cummings

    #<rule: Authors>  .+?
    <rule: Authors> 
	    #<debug: on>
	    ( <MATCH= Author> | <MATCH= AuthorList> | <ibid= (-+)> )
	    #<debug: off>
    <rule: AuthorList>
	    (<[Author]>+ % (,)) ,?
		    and
	    <LastAuthor = Author>
	    <MATCH= (?{  $MATCH = [ @{$MATCH{Author}}, $MATCH{LastAuthor} ]; })>
    <rule: Author>
	    <[AuthorPart]>+?
	    <MATCH= (?{ $MATCH =
		    do {
			    # https://rt.cpan.org/Public/Bug/Display.html?id=75797
			    # have to turn off R::G for plain regex
			    no Regexp::Grammars;
			    (join("", @{$MATCH{AuthorPart}}) =~ s,\s+, ,sgr)
		    };
	    })> 
}xms;
    #<token: AuthorPart>     \p{Uppercase}[\w.]+? # let's just assume first character is uppercase for now: no e.e. cummings

if ($references_sec =~ $reflist_parser) {
	# If successful, the hash %/ will have the hierarchy of results...
	#use DDP; &p(\%/);
	my %reflist_data = %/;
	for $cite_num (0..@{%/->{Citation}}-1) {
		next if grep { $cite_num == $_ } qw/15 19 20 22 37 46 49/;
		my $citebody = %reflist_data->{Citation}[$cite_num]{CiteBody};
		{
		no Regexp::Grammars;
		$citebody =~ s/,\s+,/,/sg;
		$citebody =~ s/\n+/ /sg;
		$citebody =~ s/\A\s+//sg;
		$citebody =~ s/\s+\Z//sg;
		}
		use DDP; p $citebody;
		if($citebody =~ $cite_parser) {
			#use DDP; &p(\%/);
			%reflist_data->{Citation}[$cite_num]{Parsed} = \%/;
		} else { exit 1; }
	}
	#process_data_in( %/ );
	use DDP; &p(\%reflist_data);
}


done_testing;
