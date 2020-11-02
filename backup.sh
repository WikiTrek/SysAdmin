#!/bin/bash
# Summary: Backup database and folder for WikiTrek
# Usage: sh backup RootDBPassword
# Author: Luca Mauri
# -------------------------------------------------

WeekNR=$((($(date +%-d)-1)/7+1))
BackupDir="/var/backups/trek/"

for DBName in wikitrek datatrek blogtrek
do
    echo "SQL Backup: $DBName"
    sudo mysqldump -u root -p"$1" "$DBName" > "$BackupDir$WeekNR$DBName".sql
    echo "XML Backup: $DBName"
    sudo mysqldump -u root -p"$1" "$DBName" --xml > "$BackupDir$WeekNR$DBName".xml	
done

echo
echo "TAR misc"
tar -cf "$BackupDir$WeekNR"apache.tar /etc/apache2/sites-available/
tar -cf "$BackupDir$WeekNR"encrypt.tar /etc/letsencrypt/live/
echo
echo "TAR WWW"
tar -cf "$BackupDir$WeekNR"www.tar /var/www/

echo
echo "GZIPping"
gzip "$BackupDir"*
