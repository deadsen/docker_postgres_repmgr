#!/bin/bash
 
set -e

PGHOST=${PRIMARY_NODE}
installed=$(psql -qAt -h "$PGHOST" -U "$REPMGR_USER" "$REPMGR_DB" -p "$PRIMARY_PORT" -c "SELECT 1 FROM pg_tables WHERE tablename='nodes'")
 
if [ "${installed}" != "1" ]; then
    echo '~~ 03: registering as primary' >&2
    repmgr primary register
    return
fi

if [ -n "$WITNESS" ]; then
	echo '~~ 03: registering as witness server' >&2
	repmgr -h "$PRIMARY_NODE" -U "$REPMGR_USER" -d "$REPMGR_DB" -p "$PRIMARY_PORT" witness register
	return
fi
 
my_node=$(grep node_id /etc/repmgr.conf | cut -d= -f 2)
is_reg=$(psql -qAt -h "$PGHOST" -U "$REPMGR_USER" "$REPMGR_DB" -p $PRIMARY_PORT -c "SELECT 1 FROM repmgr.nodes WHERE node_id=${my_node}")
 
if [ "${is_reg}" != "1" ]; then
    echo '~~ 03: registering as standby' >&2
    pg_ctl -D "$PGDATA" stop -m fast
    rm -Rf "$PGDATA"/*
    repmgr -h "$PRIMARY_NODE" -U "$REPMGR_USER" -d "$REPMGR_DB" -p "$PRIMARY_PORT" standby clone --fast-checkpoint
#    cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/
    pg_ctl -D "$PGDATA" start &
    sleep 1
    repmgr -h "$PRIMARY_NODE" -U "$REPMGR_USER" -d "$REPMGR_DB" -p "$PRIMARY_PORT" standby register    
fi
