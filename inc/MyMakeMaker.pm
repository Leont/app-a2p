package inc::MyMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

use File::Spec;
 
override _build_WriteMakefile_args => sub { +{
	%{ super() },
	NEEDS_LINKING => 1,
	C => [],
} };

override _build_MakeFile_PL_template => sub {
	my ($self) = @_;
	my $template = super();
 
	$template .= <<'TEMPLATE';
package MY;
use Config;

sub postamble {
	my $self = shift;
	my $ret = $self->SUPER::postamble;

	$ret .= "LIB = $Config{libs}\n";
	$ret .= <<'END';
OBJ = hash$(OBJ_EXT) str$(OBJ_EXT) util$(OBJ_EXT) walk$(OBJ_EXT)

$(INST_BIN)/a2p$(EXE_EXT): $(OBJ) a2p$(OBJ_EXT)
	$(CC) -o $(INST_BIN)/a2p $(LDFLAGS) $(OBJ) a2p$(OBJ_EXT) $(LIB)

pure_all :: $(INST_BIN)/a2p$(EXE_EXT)
END
	return $ret;
}
TEMPLATE
 
	return $template;
};
 
__PACKAGE__->meta->make_immutable;

no Moose;

