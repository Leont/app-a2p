#! perl

use strict;
use warnings;

use Test::More 0.89;

use Config;
use IPC::Open2;
use File::Spec::Functions 'catfile';

my $awk_path = catfile(qw{blib bin}, "a2p$Config{exe_ext}");

sub runa2p {
	my %args = @_;
	my @args = $awk_path;
	push @args, @{ $args{args} } if $args{args};
	push @args, $args{progfile} if $args{progfile};
	my $pid = open2(my ($in, $out), @args);
	print $out $args{input} if defined $args{input};
	close $out;
	binmode $in, ':crlf' if $^O eq 'MSWin32';
	my $ret = do { local $/; <$in> };
	waitpid $pid, 0;
	return $ret;
}
#TODO: runawk by piping a2p output to perl

like(runa2p(progname => '-', input => "/awk2perl/\n"), qr{print \$_ if /awk2perl/;}, 'Output looks like expected output');

done_testing;
