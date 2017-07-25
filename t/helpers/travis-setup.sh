#!/bin/bash

PGVERSION=9.6


# Main cluster set to clean slate
sudo service postgresql stop
sudo pg_dropcluster   $PGVERSION main
sudo pg_lsclusters 
sudo pg_createcluster $PGVERSION main2 # PORT 5433
sudo sh -c "cat t/helpers/config/main.conf >> /etc/postgresql/$PGVERSION/main2/postgresql.conf"
sudo service postgresql start 9.6
sudo service postgresql restart 9.6
sudo pg_ctlcluster $PGVERSION main2 start
sudo -u postgres createuser -s -p 5433 travis &>/dev/null

# create replica
sudo pg_createcluster $PGVERSION replica # PORT 5434
sudo sh -c "cat t/helpers/config/main.conf >> /etc/postgresql/$PGVERSION/replica/postgresql.conf"
sudo service postgresql stop
sudo rm -rf ~postgres/$PGVERSION/replica 
sudo -u postgres cp -r ~postgres/$PGVERSION/main2 ~postgres/$PGVERSION/replica 
sudo cp t/helpers/config/recovery.conf ~postgres/$PGVERSION/replica
sudo sh -c "cat t/helpers/config/replica.conf >> /etc/postgresql/$PGVERSION/replica/postgresql.conf"
sudo sh -c "echo 'local replication	postgres	trust' >> /etc/postgresql/$PGVERSION/main2/pg_hba.conf"
sudo pg_ctlcluster $PGVERSION main2 start
sudo service postgresql start $PGVERSION

#diagnostics and more
echo 'sleeping for 3 sec'
sudo pg_lsclusters;
sleep 3
sudo ls /var/log/postgresql/
sudo cat /etc/postgresql/$PGVERSION/main2/postgresql.conf
sudo cat /var/log/postgresql/postgresql-9.6-replica.log
echo 'MAIN LOG'
sudo cat /var/log/postgresql/postgresql-9.6-main2.log
