#!/usr/bin/env perl

use strict;
use warnings;

use Warnings::Version ();
use Test::More (Warnings::Version::massage_version($]) eq '5.6' ? ( tests => 2 ) : ( skip_all => "Only run these tests on perl 5.6") );

use IPC::Open3;

use File::Basename;
chdir dirname $0;

like( get_warning('10-version-5.006-chmod.pl'), qr/^\Qchmod() mode argument is missing initial 0/, 'chmod() warning works' );
like( get_warning('10-version-5.006-umask.pl'), qr/^\Qumask: argument is missing initial 0/, 'umask warning works' );

sub get_warning {
    my $script = shift;
    my $pid = open3(\*IN, \*OUT, \*ERR, 'perl', "-I../lib", $script);
    chomp(my $foo = <ERR>);
    waitpid($pid, 0);
    close IN;
    close OUT;
    close ERR;

    return $foo;
}

done_testing;
