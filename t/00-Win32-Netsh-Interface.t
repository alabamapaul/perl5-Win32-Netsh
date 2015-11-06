##----------------------------------------------------------------------------
## :mode=perl:indentSize=2:tabSize=2:noTabs=true:
##----------------------------------------------------------------------------
##        File: 00-Win32-Netsh-Interface.t
## Description: Test script for Win32::Netsh::Interface
##----------------------------------------------------------------------------
use strict;
use warnings;
use Test::More 0.88;

BEGIN {
  require Test::More;
  
  unless ($^O eq qq{MSWin32})
  {
    Test::More::plan(skip_all => 'Distribution is for MSWin32 only');
  }
}

use Win32::Netsh::Interface qw(:all);

diag(qq{Need to add some meaningful tests here\n});

ok(1, qq{Keep from whining about no tests!});

done_testing;
