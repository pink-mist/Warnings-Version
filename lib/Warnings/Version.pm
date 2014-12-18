use strict;
use warnings;
package Warnings::Version;

use Import::Into;

my %warnings = (
    5.20 => [ qw/ all / ],
);


sub import {
    my $version = shift;
    warnings->import::into(scalar caller, @{ $warnings{$version} });
}


1;
