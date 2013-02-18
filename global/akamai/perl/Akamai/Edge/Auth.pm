#------------------------------------------------------------------------------
# file: Auth.pm
# lib:  Akamai/Edge
# desc: provides authentication helper routines for Akamai Edge Computing
#       programs
# auth: Philip J Grabner <pgrabner@akamai.com>
# date: 2006/12/15
# copy: (C) Copyright 2006 Akamai Technologies, All Rights Reserved.
#------------------------------------------------------------------------------
# usage: Example:
#        . #!/bin/env perl
#        . 
#        . # import the perl module:
#        . use Akamai::Edge::Auth qw(urlauth_gen_url);
#        . 
#        . # call the URL-generator with appropriate parameters from cmd line:
#        . my $fullurl = Akamai::Edge::Auth::urlauth_gen_url( $ARGV[0], $ARGV[1],
#        .                                                    $ARGV[2], $ARGV[3],
#        .                                                    $ARGV[4], $ARGV[5] );
#        . # display the generated URL:
#        . print $fullurl;
#------------------------------------------------------------------------------

# This is created in the caller's space
BEGIN
{
}

#------------------------------------------------------------------------------
package Akamai::Edge::Auth;
#------------------------------------------------------------------------------

use strict; 
require 5.004;
require Digest::MD5;

#------------------------------------------------------------------------------
sub urlauth_gen_url($$$$$$)
# effects: takes a URL, time window and a salt and generates an Akamai
#          compliant authentication URL. can optionally take an extract and a
#          base time that will be used to compute the token. if the base time
#          is not specified, the current time is used. $keyname can be set
#          to undef and will default to "__gda__".
# param:   url        (string) the URL this token auth URL is being generated
#                     for, beginning with the first slash ("/") after the
#                     hostname portion of the fully qualified URL.
# param:   keyname    (string) the name of the auth token (default: "__gda__")
# param:   window     (integer) the validity of the token, in seconds
# param:   salt       (string) a salt to significantly alter the token
# param:   extract    (optional string) affects the tokenization (default: "")
# param:   basetime   (optional integer) base time for validity in UTC seconds
#                     (default: now)
# returns: an Akamai compliant Edge Authentication URL with embedded token.
{
    my ($url,$keyname,$window,$salt,$extract,$time) = @_;

    # arg check
    return undef if ! defined($window);
    $time = time() if ! defined($time);

    # calculate the token
    my $token = urlauth_gen_token( $url, $window, $salt, $extract, $time );

    # sanity check
    # tbd: don't know why $keyname is being defaulted to "__gda__"...
    #      or why "12 > keyname > 5" must be true

    $keyname = "__gda__" if ! defined $keyname;
    return undef if ( length($keyname) < 5 || length($keyname) > 12 );

    my $exp = $window + $time;

    return $url . ( $url =~ /\?/ ? '&' : '?' ) .
	$keyname . '=' . $exp . '_' . $token;
}

#------------------------------------------------------------------------------
sub urlauth_gen_token($$$$$)
# effects: takes a URL, time window and a salt and generates an Akamai
#          compliant token. can optionally take an extract and a base time
#          that will be used to compute the token. if the base time is not
#          specified, the current time is used.
# param:   url        (string) the URL this token auth URL is being generated
#                     for, beginning with the first slash ("/") after the
#                     hostname portion of the fully qualified URL.
# param:   window     (integer) the validity of the token, in seconds
# param:   salt       (string) a salt to significantly alter the token
# param:   extract    (optional string) affects the tokenization (default: "")
# param:   basetime   (optional integer) base time for validity in UTC seconds
#                     (default: now)
# returns: an Akamai compliant Edge Authentication token.
{
    my ($url,$window,$salt,$extract,$time) = @_;

    # tbd: i could test to see if $window and $time are real integers...

    # some inputs are required
    return undef if ! defined($url);
    return undef if ! defined($window);
    return undef if ! defined($salt);

    # default non-required inputs
    $extract = "" if ! defined($extract);
    $time    = time() if ! defined($time);

    # and now do the work
    my $exp  = $window + $time;

    # note: i am not using template I or N out of sheer paranoia...
    my $data = pack 'C4A*A*A*', ( $exp & 0xFF,
				  ($exp>>8) & 0xFF,
				  ($exp>>16) & 0xFF,
				  ($exp>>24) & 0xFF,
				  $url,
				  $extract,
				  $salt );

    my $md5 = Digest::MD5->new;
    $md5->reset;
    $md5->add( $data );
    my $md5out = $md5->digest;

    # tbd: should i be relying on the '.' operator here?...
    #      probably not a good idea.

    $md5->reset;
    $md5->add( $salt . $md5out );
    $md5out = $md5->hexdigest;

    return $md5out;
}

#------------------------------------------------------------------------------
# end of Auth.pm
#------------------------------------------------------------------------------
