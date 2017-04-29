#!/bin/bash

DB=/mnt/config/database/systems.db3
ROOT=/mnt/config/openwrt
SSHKEY=/mnt/config/crypto/ssh/dabkey1

# Ensure SSH authorized keys are installed on the target device
for host in `$ROOT/scripts/get_hosts.py wireless`; do
  echo Installing Authorized Keys
  scp -i $SSHKEY $ROOT/generic/etc/dropbear/authorized_keys root@$host:/etc/dropbear/authorized_keys
done

for host in `$ROOT/scripts/get_hosts.py wireless`; do
  echo Prepare System Configuration Files for $host
  $ROOT/scripts/mk_config.py $host wireless
done

echo Copy System Configuration Files to wge3
cp $ROOT/etc/rc.local          /etc/rc.local
cp $ROOT/etc/sysctl.conf       /etc/sysctl.conf
cp $ROOT/etc/config/fstab.wge3 /etc/config/fstab
cp $ROOT/root/.cpan/CPAN/MyConfig.pm /root/.cpan/CPAN/MyConfig.pm

for host in `scripts/get_hosts.py wireless`; do
  echo Copy System Configuration Files to $host
  scp -i $SSHKEY $ROOT/etc/firewall.user root@$host:/etc/firewall.user
  scp -i $SSHKEY $ROOT/etc/profile root@$host:/etc/profile
  scp -i $SSHKEY $ROOT/etc/sysupgrade.conf root@$host:/etc/sysupgrade.conf
done

echo Prepare DHCP Configuration Files
echo > $ROOT/scripts/systems.sql
echo "###Start Static DHCP Reservations###" > $ROOT/etc/config/dhcp.reservations
for csv in data/reservations/*.csv; do
  CSV=`basename $csv`
  RES=`echo $CSV | sed s/.csv//g`
  $ROOT/scripts/mk_dhcp_reservations.pl $RES $ROOT >> $ROOT/etc/config/dhcp.reservations
done
cd $ROOT/etc/config && awk '/###End Static DHCP Reservations###/ { system("cat dhcp.reservations") } { print; }' $ROOT/etc/config/dhcp.template > $ROOT/etc/config/dhcp

echo Per router DHCP Configuration - Pool
for host in `$ROOT/scripts/get_hosts.py wireless`; do
  cd $ROOT/etc/config && awk '/###End DHCP Pools###/ { system("cat dhcp.pools.wge3") } { print; }' $ROOT/etc/config/dhcp > $ROOT/etc/config/dhcp.$host
done

echo Update Device Database
echo "delete from devices;" | sqlite3 $DB
cat $ROOT/scripts/systems.sql | sqlite3 $DB

for host in `$ROOT/scripts/get_hosts.py wireless`; do
  echo Copy DHCP Configuration Files to $host
  scp -i $SSHKEY $ROOT/etc/config/dhcp.wge3 root@$host:/etc/config/dhcp
  ssh -i $SSHKEY root@$host "/etc/init.d/dnsmasq restart"
done

echo Copy RADIUS Configuration Files to wge3
/usr/bin/rsync -a $ROOT/etc/freeradius3/ /etc/freeradius3/
/etc/init.d/radiusd restart

echo Copy Wireless Configuration Files to wge3
cp $ROOT/etc/config/wireless /etc/config/wireless
#wifi

echo Make Packages Script for all devices
$ROOT/scripts/mk_packages.py

# Grab packages list from wge3
opkg list-installed | awk '{ print $1 }' | sort | uniq > $ROOT/scripts/wge3_installed.txt

echo Run Packages Script on wge3
$ROOT/scripts/wge3_packages.sh

echo Run Custom Scripts
$ROOT/scripts/custom_wge3.sh
