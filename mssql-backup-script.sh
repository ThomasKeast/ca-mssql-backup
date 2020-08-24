#!/bin/bash

# This is a script for backing up MS SQL databases on a Linux system.
# Designed to focus on one database but could be adapted as required to backup more.
#
# This script relies upon a crontab entry / schedule to work.
# The number of days of retention can be set via the variable: NUMBER_OF_DAYS_OF_BACKUPS_TO_RETAIN
# 
# The cron job is typically triggered daily with the likes of:
#
#   0 1 * * * /bin/bash /var/opt/mssql/backup/mssql-backup-script.sh &>/dev/null
#
# and can be checked by running: " crontab -l " as root.

# Variables
BACKUP_DIR="/var/opt/mssql/backup/data"
SA_USER="DATABASE-NAME"
SA_PASS="SA-USER-PASSWORD" # MS SQl usually has a "SA" user which can access all databases
NUMBER_OF_DAYS_OF_BACKUPS_TO_RETAIN="7"
TIMESTAMP=$(date +"%F")

# Main Script

# Creates backup directory
mkdir -p $BACKUP_DIR

# Performs the MS SQL database backup
/opt/mssql-tools/bin/sqlcmd -S localhost -Q "BACKUP DATABASE SOS_Datatables TO DISK = N'$BACKUP_DIR/SOS_Datatables-$TIMESTAMP.bak' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, STATS=10" -U $SA_USER -P $SA_PASS

# Removes backups that are older than 7 days
find /var/opt/mssql/backup/data/ -mindepth 1 -mtime +$NUMBER_OF_DAYS_OF_BACKUPS_TO_RETAIN -delete 

# Compresses the database backup using tar
tar -zcvf $BACKUP_DIR/SOS_Datatables-$TIMESTAMP.bak.tar.gz $BACKUP_DIR/SOS_Datatables-$TIMESTAMP.bak

# Restricts permissions on backup so that only root has r/w access
chmod 600 $BACKUP_DIR/SOS_Datatables-$TIMESTAMP.bak.tar.gz

# Remove uncompressed copy of database backup
rm -f $BACKUP_DIR/SOS_Datatables-$TIMESTAMP.bak

exit 0