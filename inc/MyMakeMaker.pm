package inc::MyMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

use File::Spec;
 
override _build_WriteMakefile_args => sub { +{
	%{ super() },
	NEEDS_LINKING => 1,
	C => [],
	MAN1PODS => {
		'lib/App/a2p.pm' => 'blib/man1/a2p.1',
	},
	MAN3PODS => {},
} };

override _build_MakeFile_PL_template => sub {
	my ($self) = @_;
	my $template = super();
 
	$template .= <<'TEMPLATE';
package MY;
use Config;

sub postamble {
	my $self = shift;
	my @ret = (
		$self->SUPER::postamble,
		'OBJ = hash$(OBJ_EXT) str$(OBJ_EXT) util$(OBJ_EXT) walk$(OBJ_EXT) a2p$(OBJ_EXT)',
		'',
		$self->catfile('$(INST_BIN)', 'a2p$(EXE_EXT)') . ' : $(OBJ)'
	);
	if ($^O eq 'MSWin32' && $Config{cc} =~ /^cl/) {
		push @ret, map { $_ eq '<<' ? $_ : "\t$_" }
		'$(LD) -subsystem:console -out:$@ @<<',
		'$(LDFLAGS) $(LDLOADLIBS) $(OBJ)',
		'<<',
		'if exist $@.manifest mt -nologo -manifest $@.manifest -outputresource:$@;1',
		'if exist $@.manifest del $@.manifest';
	}
	else {
		push @ret, "\t" . '$(CC) -o $(INST_BIN)/a2p$(EXE_EXT) $(LDFLAGS) $(OBJ) $(LIBS)';
	}
	push @ret, '', 'pure_all :: $(INST_BIN)/a2p$(EXE_EXT)';
	return join "\n", @ret;
}
TEMPLATE
 
	return $template;
};
 
__PACKAGE__->meta->make_immutable;

no Moose;

