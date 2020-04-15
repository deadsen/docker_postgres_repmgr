#!/usr/bin/env bash

sleep 30
my_node=$(grep node_id /etc/repmgr.conf | cut -d= -f 2)
check=$(psql -qAt -h "$PRIMARY_NODE" -p "$PGPOOL_PORT" -U "$REPMGR_USER" "$REPMGR_DB" -c "SELECT 1 FROM repmgr.nodes WHERE node_id=${my_node} AND type = 'primary' AND active = 'f'")
	

if [ "$check" = "1" ]; then
#	echo '!!!!========= registering as standby ========!!!!' >&2
#	
#	NEW_PORT=$(psql -qAt -h "$PRIMARY_NODE" -p "$PGPOOL_PORT" -U "$REPMGR_USER" "$REPMGR_DB" -c "SELECT conninfo FROM repmgr.nodes WHERE type = 'primary' AND active = 't'" | awk '{ print $4 }' | cut -d= -f 2)
#	pg_ctl -D "$PGDATA" start &
#        sleep 1
#        pg_ctl -D "$PGDATA" stop -m fast
#	repmgr -h "$PRIMARY_NODE" -U "$REPMGR_USER" -d "$REPMGR_DB" -p "$NEW_PORT" node rejoin --force-rewind
#
#	repmgrd --verbose

#if [ -n "$FORCED" ]; then
        echo '~~ Forced registering as standby server' >&2
        NEW_PORT=$(psql -qAt -h "$PRIMARY_NODE" -p "$PGPOOL_PORT" -U "$REPMGR_USER" "$REPMGR_DB" -c "SELECT conninfo FROM repmgr.nodes WHERE type = 'primary' AND active = 't'" | awk '{ print $4 }' | cut -d= -f 2)
        repmgr -h "$PRIMARY_NODE" -U "$REPMGR_USER" -d "$REPMGR_DB" -p "$NEW_PORT" standby clone --recovery-conf-only
        repmgr -h "$PRIMARY_NODE" -U "$REPMGR_USER" -d "$REPMGR_DB" -p "$NEW_PORT" standby register -F
        unset FORCED
        PGUSER="${PGUSER:-postgres}" \
	pg_ctl -D "$PGDATA" -w start
	sleep 4
	
	repmgrd --verbose
else	
	echo "====== Everything is OK || Starting ======"
	
	PGUSER="${PGUSER:-postgres}" \
	pg_ctl -D "$PGDATA" -w start
	sleep 4
	
	repmgrd --verbose

fi
