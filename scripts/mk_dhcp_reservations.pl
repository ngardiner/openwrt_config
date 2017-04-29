#!/mnt/external/usr/bin/perl

# Modules
use strict;

# Constants
use constant IPADDR  => 0;
use constant DEVNAME => 1;
use constant DEVLOC  => 2;
use constant MACADDR => 3;
use constant IPVADDR => 4;
use constant WPAUSER => 5;
use constant WPAPASS => 6;
use constant VLANID  => 7;
use constant FQDN    => 8;

my $file = "data/reservations/".$ARGV[0].".csv";
open(my $sql, ">> ".$ARGV[1]."/scripts/systems.sql") or die "Can't write to ".$ARGV[1]."/scripts/systems.sql";

my @data;
open(my $fh, '<', $file) or die "Can't read file '$file' [$!]\n";
while (my $line = <$fh>) {

  # Clean up the line
  chomp $line;

  # Skip header line, or remarks
  next if ($line =~ /^IP Address/);
  next if ($line =~ /^REM/);

  # Split line into fields
  my @fields = split(/,/, $line);

  # Do some value cleanup
  if ($fields[VLANID] eq "") {
    $fields[VLANID] = "0";
  }

  print $sql "INSERT OR REPLACE INTO devices \n";
  print $sql "(device_ip,name,location,device_mac,device_ipv6,wpa2_user,wpa2_password,vlan_id,fqdn) VALUES\n";
  print $sql "('".$fields[IPADDR]."','".$fields[DEVNAME]."','".
    $fields[DEVLOC]."','".$fields[MACADDR]."','".$fields[IPVADDR]."','".
    $fields[WPAUSER]."','".$fields[WPAPASS]."','".$fields[VLANID]."','".
    $fields[FQDN]."');\n";

  # Skip if there's no associated MAC address
  next if (! $fields[MACADDR]);

  print "config host\n";
  print "\toption ip\t'".$fields[IPADDR]."'\n";
  print "\toption mac\t'".$fields[MACADDR]."'\n";
  if ($fields[FQDN]) {
    print "\toption name\t'".$fields[FQDN]."'\n";
    print "\toption dns\t'1'\n";
  } else {
    print "\toption dns\t'0'\n";
  }
  if ($fields[IPVADDR]) {
    print "\toption hostid\t'".$fields[IPVADDR]."'\n";
  }
  print "\n";
}

close($sql);
