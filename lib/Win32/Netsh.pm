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
  
  my $response = netsh(qq{wlan}, qq{show}, qq{interfaces});

=cut

##****************************************************************************
##****************************************************************************
use strict;
use warnings;
use 5.010;
use Carp;
use Exporter::Easy (EXPORT => [qw(netsh)],);

## Version string
our $VERSION = qq{0.01};

##****************************************************************************
##****************************************************************************

=head2 netsh(...)

=over 2

=item B<Description>

Run the netsh command line utility with the provided arguments

=item B<Parameters>

... - Variable number of arguments

=item B<Return>

SCALAR - String captured from the standard out of the command

=back

=cut

##----------------------------------------------------------------------------
sub netsh    ## no critic (RequireArgUnpacking)
{

  ## Make sure this is a Windows box
  unless ($^O eq qq{MSWin32})
  {
    croak(
      qq{Win32::Netsh is intended for use on Microsoft Windows platforms only!}
    );
  }

  ## Build the command
  my $command = qq{netsh};
  foreach my $arg (@_)
  {
    $command .= qq{ } . $arg;
  }

  ## Execute command and capture output
  my $result = qx{$command};    ## no critic (ProhibitBacktick)

  ## return the result
  return ($result);
}

##****************************************************************************
## Additional POD documentation
##****************************************************************************

=head1 AUTHOR

Paul Durden E<lt>alabamapaul AT gmail.comE<gt>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2015 by Paul Durden.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;    ## End of module
__END__
