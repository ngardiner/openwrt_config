# OpenWRT Configuration Manager

## Introduction

The purpose of this project is to provide an OpenWRT-hosted configuration management system with minimal dependencies on the client side.

The system can be run on an OpenWRT device, which will require Perl and Python, but all of the synchronisation with the individual OpenWRT and LEDE devices is done using no more than standard shell, uci and ssh tools.

## Usage

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

### Updating

```
cd /mnt/config/openwrt
git pull
```

## Structure

### Profiles
