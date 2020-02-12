#!/bin/bash
#
# PostgreSQL Backup Script
#  Dumps postgresql databases to a file for another backup tool to pick up.
#

PATH=/usr/bin:/usr/sbin:/bin:/sbin
IFS=' '

##### START CONFIG ###################################################

DBHOST=$DB_HOST
DBPORT=$DB_PORT
DBNAME=$DB_NAME
DBUSER=$POSTGRES_USER

DIR=/usr/local/share/pgsql_dumps

# Ensure backup directory exist.
if [ ! -d "${DIR}" ]; then
    /bin/mkdir -p ${DIR}
fi

PREFIX=pgsql_backup_

##### STOP CONFIG ####################################################
FILE="${DIR}/${PREFIX}${DBNAME}_`date +%Y%m%d-%H%M%S`.sql"
COMMAND="/usr/bin/pg_dump --file=${FILE} --blobs --dbname=${DBNAME} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER}"
/bin/echo ${COMMAND} >> /test.txt
/usr/bin/pg_dump --file=${FILE} --blobs --dbname=${DBNAME} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER}
