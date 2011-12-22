#!/usr/bin/env perl

use strict;
use warnings;
# no warnings 'once';
# Turn on $OUTPUT_AUTOFLUSH
$| = 1;

use t::lib::Debugger;

my ( $dir, $pid ) = start_script('t/eg/02-sub.pl');

use Test::More;
use Test::Deep;

plan( tests => 4 );

my $debugger = start_debugger();
my $perl5db_ver;

{
	my $out = $debugger->get;

	$out =~ m/(1.\d{2})$/m;
	$perl5db_ver = $1;
	diag("perl5db version $perl5db_ver");

	# Loading DB routines from perl5db.pl version 1.28
	# Editor support available.
	#
	# Enter h or `h h' for help, or `man perldebug' for more help.
	#
	# main::(t/eg/01-add.pl:4):	$| = 1;
	#   DB<1>

	like( $out, qr/Loading DB routines from perl5db.pl version/, 'loading line' );
	like( $out, qr{main::\(t/eg/02-sub.pl:4\):\s*\$\| = 1;},     'line 4' );
}


{
	my @out = $debugger->step_in;
	cmp_deeply( \@out, [ 'main::', 't/eg/02-sub.pl', 6, 'my $x = 11;' ], 'line 6' )
		or diag( $debugger->buffer );
}

SKIP: {
	skip( 'perl5db v1.34 dose not support "c [line|sub]"', 1 ) unless $perl5db_ver < 1.34;
	my @out = $debugger->run(17);
	cmp_deeply( \@out, [ 'main::func1', 't/eg/02-sub.pl', 17, '   my $multi = $q * $w;' ], 'line 17' )
		or diag( $debugger->buffer );
}

# {
# my @out = $debugger->run(17);
# my @out = $debugger->run(17);
# cmp_deeply( \@out, [ 'main::f', 't/eg/02-sub.pl', 17, '   my $multi = $q * $w;' ], 'line 17' )
# or diag( $debugger->buffer );

# # }

{

	# Debugged program terminated.  Use q to quit or R to restart,
	#   use o inhibit_exit to avoid stopping after program termination,
	#   h q, h R or h o to get additional info.
	#   DB<1>
	my $out = $debugger->run;
	# like( $out, qr/Debugged program terminated/, 'perl debug terminated' );

	# Caused by perl5db.pl
	# if ( $perl5db_ver < 1.34 ) {
	# like( $out, qr/Debugged program terminated/ ,'test for quit perl5db version < 1.34'); # naff v1.33
	# } else {
	# like( $out, qr/Use (`q'|q) to quit or (`R'|R) to restart/ ,'test for quit perl5db version 1.34 or newer' ); # naff v1.34
	# }

}

{
	my $out = $debugger->quit;
	# like( $out, qr/1/, 'debugger quit' );
}

done_testing( );

1;

__END__