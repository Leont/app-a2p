#! perl

use strict;
use warnings;

use Test::More 0.89;

use Config;
use IPC::Open2;
use File::Spec::Functions 'catfile';
use Devel::FindPerl 'find_perl_interpreter';

alarm 5;

my $program = runa2p(progfile => '-', input => "/awk2perl/\n");
like($program, qr{print \$_ if /awk2perl/;}, 'Output looks like expected output');

my $output = runperl(input => $program, progfile => '-', args => [ $0 ]);
open my $self, '<', $0;
chomp(my @expected = grep { /awk2perl/ } <$self>);
is_deeply([ split /\n/, $output ], \@expected, 'Output is identical to … code');

done_testing;

sub run_command {
	my %args = @_;
	my @command = @{ $args{command} };
	my $pid = open2(my ($in, $out), @command) or die "Couldn't open2($?): $!";
	print $out $args{input} if defined $args{input};
	close $out;
	binmode $in, ':crlf' if $^O eq 'MSWin32';
	my $ret = do { local $/; <$in> };
	waitpid $pid, 0;
	return $ret;
}

sub runa2p {
	my %args = @_;
	my @command = catfile(qw{blib bin}, "a2p$Config{exe_ext}");
	push @command, @{ $args{args} } if $args{args};
	push @command, $args{progfile} if $args{progfile};
	return run_command(%args, command => \@command);
}

sub runperl {
	my %args = @_;
	my @command = find_perl_interpreter();
	push @command, $args{progfile} if $args{progfile};
	push @command, @{ $args{args} } if $args{args};
	return run_command(%args, command => \@command);
}
