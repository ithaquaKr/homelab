#!/bin/sh
mkdir -p $PG_UNIX_DIR
usermod -u 1001 postgres
groupmod -g 1001 postgres
chown -R postgres:postgres $PG_UNIX_DIR
su postgres -c "PATH=$PATH /usr/local/bin/patroni /var/lib/post
