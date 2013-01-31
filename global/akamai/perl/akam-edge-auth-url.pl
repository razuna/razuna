#!/usr/bin/env perl
#------------------------------------------------------------------------------
# file: akam-edge-auth-url.pl
# desc: command line interface to the Akamai::Edge::Auth perl module.
# auth: Philip J Grabner <pgrabner@akamai.com>
# date: 2006/12/15
# copy: (C) Copyright 2006 Akamai Technologies, All Rights Reserved.
#------------------------------------------------------------------------------

if ( $#ARGV < 3 || $#ARGV > 5 )
{
    print << "EOF";
usage: akam-edge-auth-url.pl URL KEYNAME WINDOW SALT [ EXTRACT [ TIME ] ]

example:
    akam-edge-auth-url.pl /path/to/resource.png __gda__ 30 secrET
EOF
    exit(1);
}

my $extract = ( $#ARGV >= 3 ? $ARGV[4] : undef );
my $time    = ( $#ARGV >= 4 ? $ARGV[5] : undef );
my $ret;

use Akamai::Edge::Auth qw(urlauth_gen_url);

$ret = Akamai::Edge::Auth::urlauth_gen_url( $ARGV[0], $ARGV[1],
					    $ARGV[2], $ARGV[3],
					    $extract, $time );

if ( ! defined $ret )
{
    printf STDERR "[**] ERROR: generating url FAILED!\n";
    exit(2);
}

print "$ret\n";

#------------------------------------------------------------------------------
# end of akam-edge-auth-url.pl
#------------------------------------------------------------------------------
