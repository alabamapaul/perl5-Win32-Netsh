package Win32::Netsh::Wlan;
##----------------------------------------------------------------------------
## :mode=perl:indentSize=2:tabSize=2:noTabs=true:
##****************************************************************************
## NOTES:
##  * Before comitting this file to the repository, ensure Perl Critic can be
##    invoked at the HARSH [3] level with no errors
##****************************************************************************

=head1 NAME

Win32::Netsh::Wlan - Provide functions in that correlate to the Microsoft 
Windows netsh utility's wlan context

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  use Win32::Netsh::Wlan qw(wlan_list_interfaces);
  
  my @wireless_if = wlan_list_interfaces();

=cut

##****************************************************************************
##****************************************************************************
use strict;
use warnings;
use 5.010;
use Readonly;
use Win32::Netsh;
use Win32::Netsh::Utils qw(:all);
use Data::Dumper;
use Exporter::Easy (
  EXPORT => [],
  OK     => [qw(wlan_list_interfaces wlan_debug)],
  TAGS   => [
    debug => [qw(wlan_debug),],
    all => [qw(:debug wlan_list_interfaces),],
    ],
);

## Version string
our $VERSION = qq{0.01};


my $debug = 0;

##-------------------------------------------------
##-------------------------------------------------
Readonly::Scalar my $WLAN_IF_KEY_LOOKUP => {
  qq{Name}                 => qq{name},
  qq{Description}          => qq{description},
  qq{GUID}                 => qq{guid},
  qq{Physical address}     => qq{mac_address},
  qq{State}                => qq{state},
  qq{SSID}                 => qq{ssid},
  qq{BSSID}                => qq{bssid},
  qq{Network type}         => qq{net_type},
  qq{Radio type}           => qq{radio},
  qq{Authentication}       => qq{auth},
  qq{Cipher}               => qq{cipher},
  qq{Connection mode}      => qq{mode},
  qq{Channel}              => qq{channel},
  qq{Receive rate (Mbps)}  => qq{rx_rate},
  qq{Transmit rate (Mbps)} => qq{tx_rate},
  qq{Signal}               => qq{signal},
};

##****************************************************************************
##****************************************************************************

=head2 wlan_debug($level)

=over 2

=item B<Description>

Set the debug level for the module

=item B<Parameters>

$level - Debug level

=item B<Return>

SCALAR - Current debug level

=back

=cut

##----------------------------------------------------------------------------
sub wlan_debug
{
  my $level = shift;
  
  $debug = $level if (defined($level));
  
  return($debug);
}

##****************************************************************************
##****************************************************************************

=head2 wlan_list_interfaces()

=over 2

=item B<Description>

Return a reference to a list of hashes that describe the wireless interfaces
available

=item B<Parameters>

NONE

=item B<Return>

ARRAY reference of hash references whose keys are as follows:
  name        - Name of the interface
  description - Description of the interface
  guid        - GUID associated with the interface
  mac_address - IEEE MAC address of the interfaces as a string
                with the format "xx:xx:xx:xx:xx:xx" where xx is a
                hexadecimal number between 00 and ff
  state       - disconnected, discovering, or connected
  ssid        - SSID of connected wireless network
  bssid       - IEEE MAC address of the associated accees point as 
                a string with the format "xx:xx:xx:xx:xx:xx" where xx
                is a hexadecimal number between 00 and ff
  net_type    - String indicating "Infrastructure" or "Ad hoc" mode
                for the connection
  radio       - String indicating if connection is 802.11b 802.11n etc.
  auth        - String indicating the type of authentication for the
                connection
  cipher      - String indicating the cypher type
  mode        - String indicating connection mode
  channel     - RF channel used for connection
  rx_rate     - Receive rate in Mbps
  tx_rate     - Receive rate in Mbps
  signal      - Signal strength as a percentage

=back

=cut

##----------------------------------------------------------------------------
sub wlan_list_interfaces
{
  my $interfaces = [];
  my $interface;

  my $command  = qq{wlan show interface};
  my $response = netsh($command);
  if ($debug >= 2)
  {
    print(qq{COMMAND:  [netsh $command]\n});
    print(qq{RESPONSE: [$response]\n});
  }
  
  foreach my $line (split(qq{\n}, $response))
  {
    print(qq{LINE: [$line]\n}) if ($debug);
    
    if ($line =~ /\A\s+ ([^:]+) \s+ : \s+ (.*)\Z/x)
    {
      my $text = str_trim($1);
      my $value = str_trim($2);
      print(qq{  TEXT:  [$text]\n  VALUE: [$value]\n}) if ($debug);
      
      if (my $key = get_key_from_lookup($text, $WLAN_IF_KEY_LOOKUP))
      {
        ## See if this is the name key
        if ($key eq qq{name})
        {
          ## If an interface is defined, push it onto the list
          push(@{$interfaces}, $interface) if (defined($interface));
          ## Initialize the interface ahsh
          $interface = initialize_hash_from_lookup($WLAN_IF_KEY_LOOKUP);
        }
        
        ## Store the value in the hash
        $interface->{$key} = $value;
      }
    }
  }
  
  ## If an interface is defined, push it onto the list
  push(@{$interfaces}, $interface) if (defined($interface));
  
  if ($debug >= 2)
  {
    print(Data::Dumper->Dump([$interfaces,], [qw(interfaces), ]), qq{\n})
  }
  return($interfaces);
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
