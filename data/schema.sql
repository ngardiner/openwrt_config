CREATE TABLE devices (device_ip varchar(16) NOT NULL, name varchar(64) NOT NULL default 'unknown', location varchar(128), device_mac varchar(25), device_ipv6 varchar(48), wpa2_user varchar(64), wpa2_password varchar(64), vlan_id integer NOT NULL default '0', fqdn varchar(256));

CREATE TABLE profile_hosts (profile varchar(32), hostname varchar(32), zonename varchar(6), timezone varchar(6), model varchar(32), primary key (hostname));
