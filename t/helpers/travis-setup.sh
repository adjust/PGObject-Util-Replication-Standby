#!/bin/bash

PGVERSION=9.6

psql -c 'ALTER SYSTEM SET max_wal_senders to 5'
psql -c 'ALTER SYSTEM SET max_replication_slots to 5'
psql -c 'ALTER SYSTEM SET wal_level to replica'
sidp pg_createcluster $PGVERSION replica
sudo service postgresql stop
sudo -u postgres rm -rf ~/$PGVERSION/replica 
sudo -u postgres cp -r ~/$PGVERSION/main ~/$PGVERSION/replica 
sudo cp t/helpers/recovery.conf ~/$PGVERSION/replica
sudo chown postgres  ~/$PGVERSION/replica/recovery.conf
sudo service postgresql start $PGVERSION
