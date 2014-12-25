#!/usr/bin/env perl

use strict;
use Warnings::Version 'all';
no warnings 'portable';

#my $time = gmtime('NaN'); # don't do this ... causes segmentation fault on 5.20.1

my $num = 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
