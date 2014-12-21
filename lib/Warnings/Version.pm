use strict;
use warnings;
package Warnings::Version;

use Import::Into;

my %warnings;
$warnings{ categories } = [ qw/ all io severe syntax utf8 experimental / ];
$warnings{ all        } = [ qw/ closure exiting glob io closed exec newline pipe unopened misc
    numeric once overflow pack portable recursion redefine regexp debugging inplace internal malloc
    signal substr syntax ambiguous bareword deprecated digit parenthesis precedence printf prototype
    qw reserved semicolon taint uninitialized unpack untie void / ];
$warnings{ '5.6'      } = [ @{ $warnings{all} }, qw/ chmod umask utf8 y2k / ];
$warnings{ '5.8'      } = [ @{ $warnings{all} }, qw/ layer threads utf8 y2k / ];
$warnings{ '5.10'     } = [ @{ $warnings{all} }, qw/ layer threads utf8 / ];
$warnings{ '5.12'     } = [ @{ $warnings{all} }, qw/ layer imprecision illegalproto threads utf8 / ];
$warnings{ '5.14'     } = [ @{ $warnings{all} }, qw/ layer imprecision illegalproto threads surrogate
    non_unicode nonchar / ];
$warnings{ '5.16'     } = [ @{ $warnings{all} }, qw/ layer imprecision illegalproto threads surrogate
    non_unicode nonchar / ];
$warnings{ '5.18'     } = [ @{ $warnings{all} }, qw/ experimental::lexical_subs imprecision layer
    illegalproto threads utf8 non_unicode nonchar surrogate / ];
$warnings{ '5.20'     } = [ @{ $warnings{all} }, qw/ experimental::autoderef
    experimental::lexical_subs experimental::lexical_topic experimental::postderef
    experimental::regex_sets experimental::signatures experimental::smartmatch imprecision layer
    syscalls illegalproto threads utf8 non_unicode nonchar surrogate / ];


sub import {
    my $package = shift;
    my $version = shift;
    warnings->import::into(scalar caller, get_warnings($version, $]));
}

sub get_warnings {
    my $version      = massage_version(shift);
    my $perl_version = massage_version(shift);

    die "Unknown version: $version\n"           unless defined $warnings{ $version };
    die "Unknown perl version: $perl_version\n" unless defined $warnings{ $perl_version };

    my $wanted       = $warnings{ $version       };
    my $available    = $warnings{ $perl_version };

    return intersection( $wanted, $available );
}

sub massage_version {
    local $_ = shift;

    s/(5\.\d+)\..*/$1/;
    s/(5\.\d\d\d).*/$1/;
    s/(5\.)0*/$1/;

    return $_;
}

sub intersection {
    my ($a1, $a2) = @_;
    my %count;

    return grep { $count{$_}++ == 1 } @{ $a1 }, @{ $a2 };
}


1;
