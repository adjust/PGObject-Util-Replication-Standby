#!/bin/bash

PGVERSION=9.6

psql -c 'ALTER SYSTEM SET max_wal_senders to 5'
psql -c 'ALTER SYSTEM SET max_replication_slots to 5'
psql -c 'ALTER SYSTEM SET wal_level to replica'
sudo pg_createcluster $PGVERSION replica
sudo service postgresql stop
sudo rm -rf ~postgres/$PGVERSION/replica 
sudo -u postgres cp -r ~postgres/$PGVERSION/main ~postgres/$PGVERSION/replica 
sudo cp t/helpers/config/recovery.conf ~postgres/$PGVERSION/replica
sudo cat t/hel[ers/config/replica.conf >> /etc/postgresql/$PGVERSION/postgresql.conf
sudo service postgresql start $PGVERSION
echo 'sleeping for 3 sec'
sleep 3
sudo ls /var/log/postgresql/
