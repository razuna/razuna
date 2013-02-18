OVERVIEW

The Akamai/Edge/Auth package is designed to help you incorporate
URL-based Edge Authorization / distributed authentication tokens
into your site.

Read the akam-edge-auth-url.pl file for a sample of how to
create Akamai Edge Authorization URLs by invoking the
Akamai::Edge::Auth::urlauth_gen_url() subroutine. Please also
read the documentation in Akamai/Edge/Auth.pm for details
on what parameters to pass the subroutine.

INSTALLATION

Copy the file "Akamai/Edge/Auth.pm" into your perl library
(eg. PERL5LIB) that is active for whatever environment you would
like to use the module.

CONTENTS

This archive contains the following items:

Akamai/Edge/Auth.pm
    The perl module implementing the subroutine to create
    a URL-based authorization token.

akam-edge-auth-url.pl
    a command line version that demonstrates the use of the
    Akamai/Edge/Auth.pm module and enables command line testing.

README.txt
    A summary of the package along with integration information

ChangeLog.txt
    A list of package changes, by version
