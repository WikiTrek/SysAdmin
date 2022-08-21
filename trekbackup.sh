#!/bin/bash
# Summary: Backup database and folder for WikiTrek
# Usage: sudo sh trekbackup.sh
# Author: Luca Mauri
# -------------------------------------------------

WeekNR=$((($(date +%-d)-1)/7+1))
BackupDir="/var/backups/trek/"

echo "Writing to $BackupDir"
echo
for DBName in wikitrek datatrek blogtrek
do
    echo "SQL Backup: $DBName"
    sudo mysqldump -u root "$DBName" > "$BackupDir$WeekNR$DBName".sql
    echo "XML Backup: $DBName"
    sudo mysqldump -u root "$DBName" --xml > "$BackupDir$WeekNR$DBName".xml
done

echo
echo "TAR misc"
tar -cf "$BackupDir$WeekNR"apache.tar /etc/apache2/sites-available/
sudo tar -cf "$BackupDir$WeekNR"encrypt.tar /etc/letsencrypt/live/

echo
echo "TAR WWW"
sudo tar -cf "$BackupDir$WeekNR"www.tar /var/www/

echo
echo "GZIPping"
rm -v ${BackupDir}${WeekNR}*.gz
gzip ${BackupDir}*
