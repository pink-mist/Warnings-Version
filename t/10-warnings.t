#!/usr/bin/env perl

use strict;
use warnings;

use IPC::Open3;
use File::Basename;
use Config;


use Test::More;

# 1
BEGIN { use_ok( 'Warnings::Version', 'all' ); }



my $prefix       = dirname $0;
my $name         = "Warnings/Version.pm";
my $inc          = $INC{$name}; $inc =~ s/\Q$name\E$//;
my $perl_interp  = $^X;
my $perl_version = Warnings::Version::massage_version($]);

SKIP: {
    skip "Chmod and umask warning categories only exist on perl 5.6", 2 unless $perl_version eq '5.6';

    # 2 .. 3
    like( get_warning('10-version-5.006-chmod.pl'), qr/^\Qchmod() mode argument is missing initial 0/, 'chmod warning works' );
    like( get_warning('10-version-5.006-umask.pl'), qr/^\Qumask: argument is missing initial 0/, 'umask warning works' );
};

SKIP: {
    skip "Y2K warnings only exist on perls 5.6 and 5.8", 1 unless grep { $perl_version eq $_ } qw/ 5.6 5.8 /;
    skip "Only run this test if perl has been built with Y2K warnings enabled", 1 unless $Config{ccflags} =~ /Y2KWARN/;

    # 4
    like( get_warning('10-y2k.pl'), qr/^\QPossible Y2K bug: about to append an integer to '19'/, 'y2k warning works' );
};

SKIP: {
    skip "There are no utf8 warnings on perls 5.14 or 5.16", 1, if grep { $perl_version eq $_ } qw/ 5.14 5.16 /;

    # 5
    like( get_warning('10-utf8.pl'), qr/^\QMalformed UTF-8 character/, 'utf8 warning works' );
};

SKIP: {
    skip "Layer warning category doesn't exist on perl 5.6", 1 if $perl_version eq '5.6';

    # 6
    like( get_warning('10-layer.pl'), qr/^\Qperlio: argument list not closed for layer "encoding(UTF-8"/, 'layer warning works' );
};

# 7
like( get_warning('10-closure.pl'), qr/^\QVariable "\E\$\Qfoo" may be unavailable/, 'closure warning works' );
like( get_warning('10-exiting.pl'), qr/^\QExiting eval via last/, 'exiting warning works' );


sub get_warning {
    my $script = "$prefix/$_[0]";
    if (not -f $script) {
        fail("Warning script not found: $script");
        return "Error: No such file: $script";
    }
    my $pid = open3(\*IN, \*OUT, \*ERR, $perl_interp, "-I$inc", "$script");
    chomp(my $foo = <ERR>);
    waitpid($pid, 0);
    close IN;
    close OUT;
    close ERR;

    return $foo;
}

done_testing;
