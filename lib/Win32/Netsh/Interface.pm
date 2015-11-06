package Win32::Netsh::Interface;
##----------------------------------------------------------------------------
## :mode=perl:indentSize=2:tabSize=2:noTabs=true:
##****************************************************************************
## NOTES:
##  * Before comitting this file to the repository, ensure Perl Critic can be
##    invoked at the HARSH [3] level with no errors
##****************************************************************************

=head1 NAME

Win32::Netsh::Interface - Provide functions in that correlate to the Microsoft 
Windows netsh utility's interface context

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  use Win32::Netsh::Interface qw(interface_ipv4_info);
  
  my @ip_addresses = interface_ipv4_info(qq{Local Area Network});

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
  OK     => [qw(interface_ipv4_info interface_ipv4_info_all interface_debug)],
  TAGS   => [
    debug => [qw(interface_debug),],
    all   => [qw(:debug interface_ipv4_info interface_ipv4_info_all),],
  ],
);

## Version string
our $VERSION = qq{0.01};

my $debug           = 0;
my $interface_error = qq{};

##-------------------------------------------------
##-------------------------------------------------
Readonly::Scalar my $IPV4_KEY_LOOKUP => {
  qq{DHCP enabled}    => qq{dhcp},
  qq{IP Address}      => qq{ip},
  qq{Subnet Prefix}   => qq{netmask},
  qq{Default Gateway} => qq{gateway},
  qq{Gateway Metric}  => qq{gw_metric},
  qq{InterfaceMetric} => qq{if_metric},
};

##****************************************************************************
## Functions
##****************************************************************************

=head1 FUNCTIONS

=cut

##****************************************************************************
##****************************************************************************

=head2 interface_debug($level)

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
sub interface_debug
{
  my $level = shift;

  $debug = $level if (defined($level));

  return ($debug);
}

##----------------------------------------------------------------------------
##     @fn _netmask_add($info, $string)
##  @brief Parse the string and add the netmask to the given info hash
##  @param $info - Hash reference containing the netmask key
##  @paeam $string - String to parse
## @return NONE
##   @note
##----------------------------------------------------------------------------
sub _netmask_add
{
  my $info = shift;
  my $string = shift // qq{};

  if ($string =~ /\(mask (.*)\)/x)
  {
    if (my $mask = parse_ip_address($1))
    {
      push(@{$info->{netmask}}, $mask);
    }
  }

  return;
}

##----------------------------------------------------------------------------
##     @fn _parse_ipv4_response($lines)
##  @brief Parse the repsonse into an ipv4 info hash
##  @param $lines = Array reference of netsh response
## @return HASH reference or undef
##   @note
##----------------------------------------------------------------------------
sub _parse_ipv4_response
{
  my $lines = shift;
  my $info;

  print(qq{_parse_ipv4_response()\n}) if ($debug);
  print(Data::Dumper->Dump([$lines,], [qw(lines),]), qq{\n}) if ($debug >= 2);

IPV4_PARSE_LOOP:
  while (1)
  {
    my $line = shift(@{$lines});
    last IPV4_PARSE_LOOP unless (defined($line));
    print(qq{LINE: [$line]\n}) if ($debug);
    if (length($line) == 0)
    {
      ## This is a blank line

      ## If the info hash is defined, stop processing
      last IPV4_PARSE_LOOP if (defined($info));
    }
    elsif ($line =~ /Configuration \s+ for \s+ interface \s+ "(.*)"/x)
    {
      ## Initialize the hash
      $info            = initialize_hash_from_lookup($IPV4_KEY_LOOKUP);
      $info->{name}    = $1;
      $info->{ip}      = [];
      $info->{netmask} = [];
    }
    elsif ($line =~ /\A\s+ ([^:]+): \s+ (.*)\Z/x)
    {
      my $text  = str_trim($1);
      my $value = str_trim($2);
      print(qq{  TEXT:  [$text]\n  VALUE: [$value]\n}) if ($debug);

      if (my $key = get_key_from_lookup($text, $IPV4_KEY_LOOKUP))
      {
        if ($key eq qq{netmask})
        {
          _netmask_add($info, $value);
        }
        elsif ($key eq qq{ip})
        {
          if (my $ip = parse_ip_address($value))
          {
            push(@{$info->{ip}}, $ip);
          }
        }
        elsif ($key eq qq{gateway})
        {
          if (my $ip = parse_ip_address($value))
          {
            $info->{gateway} = $ip;
          }
        }
        else
        {
          $info->{$key} = $value;
        }
      }
    }
  }

  if ($debug >= 2)
  {
    print(Data::Dumper->Dump([$info,], [qw(info),]), qq{\n});
  }
  return ($info);
}

##****************************************************************************
##****************************************************************************

=head2 interface_ipv4_info($name)

=over 2

=item B<Description>

Return a hash reference with the IPV4 information for the given interface

=item B<Parameters>

=over 4

=item I<$name>

Name of the interface

=back

=item B<Return>

HASH reference whose keys are as follows:

=over 4

=item I<name>

Name of the interface

=item I<dhcp>

Indicates if DHCP is enabled

=item I<ip>

Array reference containing IP addresses for the interface

=item I<netmask>

Array reference containing netmasks for the interface

=item I<gateway>

IP address of the default gateway for the interface

=item I<gw_metric>

Gateway metric

=item I<if_metric>

Interface metric

=back

=back

=cut

##----------------------------------------------------------------------------
sub interface_ipv4_info
{
  my $name = shift // qq{};

  my $command  = qq{interface ipv4 show addresses name="$name"};
  my $response = netsh($command);
  if ($debug >= 2)
  {
    print(qq{COMMAND:  [netsh $command]\n});
    print(qq{RESPONSE: [$response]\n});
  }

  my $lines = [split(qq{\n}, $response)];

  return (_parse_ipv4_response($lines));
}

##****************************************************************************
##****************************************************************************

=head2 interface_ipv4_info_all()

=over 2

=item B<Description>

Return an array reference that contains hash reference with the IPV4 
information for each interface

=item B<Parameters>

NONE

=item B<Return>

ARRAY reference of hash references whose keys are as follows:

=over 4

=item I<name>

Name of the interface

=item I<dhcp>

Indicates if DHCP is enabled

=item I<ip>

Array reference containing IP addresses for the interface

=item I<netmask>

Array reference containing netmasks for the interface

=item I<gateway>

IP address of the default gateway for the interface

=item I<gw_metric>

Gateway metric

=item I<if_metric>

Interface metric

=back

=back

=cut

##----------------------------------------------------------------------------
sub interface_ipv4_info_all
{
  my $lines = [];
  my $all   = [];

  my $command  = qq{interface ipv4 show addresses};
  my $response = netsh($command);
  if ($debug >= 2)
  {
    print(qq{COMMAND:  [netsh $command]\n});
    print(qq{RESPONSE: [$response]\n});
  }

  @{$lines} = split(qq{\n}, $response);

  while (my $info = _parse_ipv4_response($lines))
  {
    push(@{$all}, $info);
  }

  if ($debug >= 2)
  {
    print(Data::Dumper->Dump([$all,], [qw(all),]), qq{\n});
  }
  return ($all);
}

##****************************************************************************
##****************************************************************************

=head2 interface_last_error()

=over 2

=item B<Description>

Return the error string associated with the last command

=item B<Parameters>

NONE

=item B<Return>

SCALAR - Error string

=back

=cut

##----------------------------------------------------------------------------
sub wlan_last_error
{
  return ($wlan_error);
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
