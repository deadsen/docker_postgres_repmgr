#!/bin/bash 
 
set -e

echo '~~ 02: repmgr conf' >&2
 
PGHOST=${PRIMARY_NODE}
 
echo "*:*:*:$REPMGR_USER:$REPMGR_PASSWORD" > /var/lib/postgresql/.pgpass
chmod go-rwx /var/lib/postgresql/.pgpass

