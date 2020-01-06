#!/bin/bash
# Backup database and folder for WikiTrek

WeekNR = $((($(date +%-d)-1)/7+1))

mysqldump --user=wtstaff -ppswd wikitrek > /var/backups/$WeekNRwikitrekorg.sql
mysqldump --user=wtstaff -ppswd wikitrek --xml > /var/backups/$WeekNRwikitrekorg.xml

tar -cvf /var/backups/$WeekNRwikitrekorg.tar /var/www/wikitrek

gzip /var/backups/$WeekNRwiki*
