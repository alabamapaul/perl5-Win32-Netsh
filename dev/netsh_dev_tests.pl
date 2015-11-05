#!/usr/bin/perl -w
##----------------------------------------------------------------------------
## :mode=perl:indentSize=2:tabSize=2:noTabs=true:
##----------------------------------------------------------------------------
##        File: netsh_dev_tests.pl
## Description: Script for testing the various module interfaces
##----------------------------------------------------------------------------
## CHANGES:
##
##----------------------------------------------------------------------------
use strict;
use warnings;
## Cannot use Find::Bin because script may be invoked as an
## argument to another script, so instead we use __FILE__
use File::Basename qw(dirname fileparse basename);
use File::Spec;
## Add script directory
use lib File::Spec->catdir(File::Spec->splitdir(dirname(__FILE__)));
## Add script directory/lib
use lib File::Spec->catdir(File::Spec->splitdir(dirname(__FILE__)), qq{lib});
## Add script directory/../lib
use lib File::Spec->catdir(
  File::Spec->splitdir(dirname(__FILE__)),
  qq{..},
  qq{lib}
  );
use Win32::Netsh::Wlan qq(:all);
use Win32::Netsh::Interface qq(:all);


wlan_debug(3);

wlan_list_interfaces();

interface_debug(3);

interface_ipv4_info(qq{Local Area Connection 2});

interface_ipv4_info(qq{Wireless Network Connection});

interface_ipv4_info(qq{BOGUS});

interface_ipv4_info_all();

__END__