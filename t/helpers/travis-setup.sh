#!/bin/bash

PGVERSION=9.6

sudo service postgresql stop
sudo pg_dropcluster $PGVERSION main
sudo pg_createcluster $PGVERSION main

sudo sh -c "cat t/helpers/config/main.conf >> /etc/postgresql/$PGVERSION/main/postgresql.conf"
sudo service postgresql start 9.6
sudo pg_createcluster $PGVERSION replica
sudo sh -c "cat t/helpers/config/main.conf >> /etc/postgresql/$PGVERSION/replica/postgresql.conf"
sudo service postgresql stop
sudo rm -rf ~postgres/$PGVERSION/replica 
sudo -u postgres cp -r ~postgres/$PGVERSION/main ~postgres/$PGVERSION/replica 
sudo cp t/helpers/config/recovery.conf ~postgres/$PGVERSION/replica
sudo sh -c "cat t/helpers/config/replica.conf >> /etc/postgresql/$PGVERSION/replica/postgresql.conf"
sudo sh -c "echo 'local replication	postgres	trust' >> /etc/postgresql/$PGVERSION/main/pg_hba.conf"
sudo service postgresql start $PGVERSION
echo 'sleeping for 3 sec'
sleep 3
sudo ls /var/log/postgresql/
sudo cat /etc/postgresql/$PGVERSION/main/postgresql.conf
sudo cat /var/log/postgresql/postgresql-9.6-replica.log
echo 'MAIN LOG'
sudo cat /var/log/postgresql/postgresql-9.6-main.log
