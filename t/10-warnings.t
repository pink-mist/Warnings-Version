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

my %warnings = (
    closure   => qr/^(Variable "\$foo" may be unavailable|Variable "\$foo" will not stay shared)/,
    exiting   => qr/^\QExiting eval via last/,
    io        => qr/^Filehandle (main::)?STDIN opened only for input/,
    glob      => "Not sure how to cause a glob category warning",
    closed    => qr/^\Qreadline() on closed filehandle \E(main::)?STDIN/,
    exec      => qr/^\QStatement unlikely to be reached/,
    newline   => qr/^\QUnsuccessful stat on filename containing newline/,
    pipe      => qr/^\QMissing command in piped open/,
    unopened  => qr/^(\Qclose() on unopened filehandle FOO\E|\QClose on unopened file <FOO>\E)/,
    misc      => qr/^\QOdd number of elements in hash assignment/,
    numeric   => qr/^\QArgument "foo" isn't numeric in repeat (x)/,
    once      => qr/^\QName "main::foo" used only once: possible typo/,
    overflow  => qr/^\QInteger overflow in hexadecimal number/,
    pack      => qr/^\QAttempt to pack pointer to temporary value/,
    portable  => qr/^\QHexadecimal number > 0xffffffff non-portable/,
    recursion => qr/^\QDeep recursion on subroutine "main::foo"/,
    redefine  => qr/^\QSubroutine foo redefined/,
    regexp    => qr!^(
        \QFalse [] range "a-\d" in regex; marked by <-- HERE in m/[a-\d <-- HERE ]/\E
              |
        \Q/[a-\d]/: false [] range "a-\d" in regexp\E
              |
        \QFalse [] range "a-\d" before HERE mark in regex m/[a-\d << HERE ]/\E
        )!x,
    debugging => "Not sure how to cause a debugging warning",
    inplace   => qr/^Can't open .*nonexistant: /,
    internal  => "Not sure how to cause an internal warning",
    malloc    => "Not sure how to cause a malloc warning",
    signal    => qr/\QNo such signal: SIGFOOBAR/,
);

my @warnings = Warnings::Version::get_warnings('all', 'all');
foreach my $warning (@warnings) {
    SKIP: {
        skip "Warning $warning not implemented", 1 unless exists $warnings{$warning};
        skip $warnings{$warning}, 1                unless ref $warnings{$warning} eq 'Regexp';

        like( get_warning("10-helpers/$warning.pl"), $warnings{$warning}, "$warning warnings works ($^X)" );
    };
}


SKIP: {
    skip "Chmod and umask warning categories only exist on perl 5.6", 2 unless $perl_version eq '5.6';

    like( get_warning('10-helpers/version-5.006-chmod.pl'), qr/^\Qchmod() mode argument is missing initial 0/, 'chmod warning works' );
    like( get_warning('10-helpers/version-5.006-umask.pl'), qr/^\Qumask: argument is missing initial 0/, 'umask warning works' );
};

SKIP: {
    skip "Y2K warnings only exist on perls 5.6 and 5.8", 1                        unless grep { $perl_version eq $_ } qw/ 5.6 5.8 /;
    skip "Only run this test if perl has been built with Y2K warnings enabled", 1 unless $Config{ccflags} =~ /Y2KWARN/;

    like( get_warning('10-helpers/y2k.pl'), qr/^\QPossible Y2K bug: about to append an integer to '19'/, 'y2k warning works' );
};

SKIP: {
    skip "There are no utf8 warnings on perls 5.14 or 5.16", 1, if grep { $perl_version eq $_ } qw/ 5.14 5.16 /;

    like( get_warning('10-helpers/utf8.pl'), qr/^\QMalformed UTF-8 character/, 'utf8 warning works' );
};

SKIP: {
    skip "Layer warning category doesn't exist on perl 5.6", 1 if $perl_version eq '5.6';

    like( get_warning('10-helpers/layer.pl'), qr/^(perlio: a|A)rgument list not closed for (PerlIO )?layer "encoding\(UTF-8"/, 'layer warning works' );
};

sub get_warning {
    my $script = "$prefix/$_[0]";
    if (not -f $script) {
        fail("Warning script not found: $script");
        return "Error: No such file: $script";
    }
    my $pid = open3(\*IN, \*OUT, \*ERR, $perl_interp, "-I$inc", "$script");
    my $foo = <ERR>;
    $foo = "" unless defined $foo;
    chomp($foo);
    waitpid($pid, 0);
    close IN;
    close OUT;
    close ERR;

    return $foo;
}

done_testing;
