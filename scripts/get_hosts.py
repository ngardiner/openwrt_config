#!/mnt/external/usr/bin/python

# Packages to import
import sqlite3
import sys

# Connect to sqlite database
conn = sqlite3.connect(sys.argv[2])

if (sys.argv[1] != 'all'):
	cursor = conn.execute("SELECT hostname FROM profile_hosts WHERE profile = '"+sys.argv[1]+"' ORDER BY hostname ASC")
	for row in cursor:
		print row[0]

if (sys.argv[1] == 'all'):
	cursor = conn.execute("SELECT hostname FROM profile_hosts ORDER BY hostname ASC")
	for row in cursor:
		print row[0]

conn.close()
