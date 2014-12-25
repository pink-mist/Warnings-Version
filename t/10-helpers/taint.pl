#!/usr/bin/env perl

use strict;
use Warnings::Version 'all';
use File::Basename;

my $name = 'Warnings/Version.pm';
my $inc  = $INC{$name}; $inc =~ s/\Q$name\E$//;

my $foo = $ENV{PATH} . kill 0;

system( $^X, '-T', "-I$inc", $0 ) or die "Taint check didn't kill us";
    # $^X is the currently running perl interpreter
    # when this is run with -T, it should die before calling system()
