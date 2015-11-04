package Win32::Netsh;
##----------------------------------------------------------------------------
## :mode=perl:indentSize=2:tabSize=2:noTabs=true:
##****************************************************************************
## NOTES:
##  * Before comitting this file to the repository, ensure Perl Critic can be
##    invoked at the HARSH [3] level with no errors
##****************************************************************************
=head1 NAME

Win32::Netsh - A family of modules for querying and manipulating the network
insterface of a Windows based PC using the netsh utility

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  use Win32::Netsh;
  
  my $response = win32_netsh(qq{wlan}, qq{show}, qq{interfaces});

=cut

##****************************************************************************
##****************************************************************************
use strict;
use warnings;
use 5.010;

## Version string
our $VERSION = qq{0.01};


1;
