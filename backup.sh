#!/bin/bash
# Backup database and folder for WikiTrek

WeekNR = $((($(date +%-d)-1)/7+1))

mysqldump --user=wtstaff -p wikitrek > /var/backups/$WeekNRwikitrekorg.sql
mysqldump --user=wtstaff -p wikitrek --xml > /var/backups/$WeekNRwikitrekorg.xml

tar -cvf /var/backups/$WeekNRwikitrekorg.tar /var/www/wikitrek

gzip $WeekNRwiki*
