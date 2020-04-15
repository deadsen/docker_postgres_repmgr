FROM postgres:10

# PostgreSQL 10 docker image with
# repmgr and pg_recall
# (and pg_stat_statements is enabled in postgresql.conf)

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main 10" \
          >> /etc/apt/sources.list.d/pgdg.list
 
# override this on secondary nodes

ENV PRIMARY_NODE=localhost

ENV REPMGR_USER=repl
ENV REPMGR_DB=repldb
ENV PG_PORT=5432
RUN apt-get update; apt-get install -y git make postgresql-server-dev-10 libpq-dev postgresql-10-repmgr repmgr-common

RUN mkdir /run/repmgr/ && chown postgres:postgres /run/repmgr

RUN mkdir /tmp/scripts; chown postgres:postgres /tmp/scripts/

COPY postgresql.conf /tmp/
COPY docker-entrypoint.sh /usr/local/bin/

COPY scripts/* /docker-entrypoint-initdb.d/

COPY start/* /tmp/scripts/

