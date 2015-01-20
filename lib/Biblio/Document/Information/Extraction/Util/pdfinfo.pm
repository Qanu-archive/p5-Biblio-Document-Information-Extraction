package Biblio::Document::Information::Extraction::Util::pdfinfo;

use strict;
use warnings;

use IPC::Run3;

=method pdfinfo( %arguments )

Returns a HashRef of data from the C<pdfinfo> command.

C<%arguments>

=over 4

=item * file => $filepath

=item * stream => $pdf_content

=back

=cut
sub pdfinfo {
	my ($self, %args) = @_;
	my ($in, $out, $err);

	my $pdfinfo_arg;
	if( exists $args{file} ) {
		die "File not found: $args{file}" unless -f $args{file};

		$pdfinfo_arg = $args{file};
		$in = undef;
	} elsif( exists $args{stream} ) {
		$pdfinfo_arg = '-';
		$in = $args{stream}
	}

	my $cmd = [ 'pdfinfo', $pdfinfo_arg ];
	# NOTE: this uses the shell
        run3 $cmd, \$in, \$out, \$err;

	my $msg = "could not get PDF information" . ( defined $err ? " : $err" : "" );
	die $msg if $?;

	my @lines = split /\n/, $out;
	@lines = grep { $_ ne '' } @lines;

	my $info = {};
	for my $line (@lines) {
		my ($key, $value) = split /:\s*/, $line, 2;
		$info->{$key} = $value;
	}

	return $info;
}


1;
