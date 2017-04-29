# OpenWRT Configuration Manager

## Introduction

The purpose of this project is to provide an OpenWRT-hosted configuration management system with minimal dependencies on the client side.

The system can be run on an OpenWRT device, which will require Perl and Python, but all of the synchronisation with the individual OpenWRT and LEDE devices is done using no more than standard shell, uci and ssh tools.

A number of different interpreters are used - no working DBI for sqlite exists for perl, so python scripts are used 

Project Status: Very Alpha

### Prerequisites

```
opkg update
opkg install perl python
```

### Usage

Create directories for the configuration system and database:

```
mkdir /mnt/config
mkdir /mnt/config/database
```

Clone Repository
```
cd /mnt/config
git clone https://github.com/ngardiner/openwrt_config openwrt
```

Create the sqlite database
```
cat data/schema.sql | sqlite3 /mnt/config/database/system.db3
```

Add a host to be managed 
```
insert into profile_hosts values ('wireless','wge3','Australia/Melbourne','AEST-10AEDT,M10.1.0,M4.1.0/3','archerc7');
```

### Updating

```
cd /mnt/config/openwrt
git pull
```

## Structure

### DHCP Reservations

The OpenWRT Configuration Manager system has an in-built IPAM (IP Allocation Management) function, via CSV files located in the data/reservations/ directory. There can be one or many CSV files, which allows the allocations to be split between files.

There are no specific requirements in terms of the data located in any one file. Subnets can be split between different CSV files, and 

### Profiles

Profiles are used to direct the system on how to 
