# postgres-repmgr
PostgreSQL Docker image with repmgrd and pgpool for automatic failover


This is heavily based on [postdock](https://github.com/paunin/PostDock) and https://github.com/mreithub/postgres-repmgr, but:

- several environment variables have been added
- a few other minor changes

Environment:

This docker image uses the following environment variables (with their defaults if applicable):

- `REPMGR_USER=repmgr`
- `REPMGR_DB=repmgr`
- `REPMGR_PASSWORD` (required)  
  Use something like `pwgen -n 24 1` to generate a random one (and make sure you use the same one on all your nodes
- `WITNESS=`
  If non-empty, this node is set up as witness node (i.e. won't hold actual data but still has a vote in leader election).  

My modifications:
   env variables:
 - `PGPOOL_PORT` - for some failover checks
   
