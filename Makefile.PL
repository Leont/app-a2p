use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Spec;
 
my %args = (
##{ $plugin->get_default(qw(NAME ABSTRACT AUTHOR LICENSE VERSION EXE_FILES)) ##}
##{ $plugin->get_prereqs(1) ##}
  NEEDS_LINKING => 1,
  C => [],
);
 
unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $args{TEST_REQUIRES};
  my $br = $args{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}
 
unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $args{BUILD_REQUIRES};
  my $pp = $args{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}
 
delete $args{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };
 
delete $args{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };
 
WriteMakefile(%args);
 
package MY;
use Config;

sub postamble {
	my $self = shift;
	my $ret = $self->SUPER::postamble;

	$ret .= "LIB = $Config{libs}\n";
	$ret .= sprintf <<'END', ;
OBJ = hash$(OBJ_EXT) str$(OBJ_EXT) util$(OBJ_EXT) walk$(OBJ_EXT)

$(INST_BIN)/a2p$(EXE_EXT): $(OBJ) a2p$(OBJ_EXT)
	$(CC) -o $(INST_BIN)/a2p $(LDFLAGS) $(OBJ) a2p$(OBJ_EXT) $(LIB)

pure_all :: $(INST_BIN)/a2p$(EXE_EXT)
END

}
