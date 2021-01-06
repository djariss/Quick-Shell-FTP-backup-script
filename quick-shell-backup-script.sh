#!/bin/sh
# Backup script that copies /var/www content and all MySQL bases
# then the content is uploaded onto FTP storage.
# Just change the credentials in the FTP server Setup part of script and you are good to g. :)
# Created by Davor Veselinovic in 2012
# ---------------------------------------------------------------------

# System Setup #
DIRS="/var/www"
BACKUP=/tmp/backup.$$
NOW=$(date +"%d-%m-%Y")
INCFILE="/root/tar-inc-backup.dat"
DAY=$(date +"%a")
FULLBACKUP="Mon"

# MySQL Settings #
MUSER="root"
MPASS="your_mysql_root_password"
MHOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# FTP server credentials #
FTPD="FTP_directory"
FTPU="FTP_username"
FTPP="your_FTP_password"
FTPS="FTP_address_or_host"
NCFTP="$(which ncftpput)"

# Email notification #
EMAILID="enter_email_for_notifications"

# Backup the file system #
[ ! -d $BACKUP ] && mkdir -p $BACKUP || :

# Check if we need to make Full backup #
if [ "$DAY" == "$FULLBACKUP" ]; then
  FTPD="//full"
  FILE="fs-full-$NOW.tar.gz"
  tar -zcvf $BACKUP/$FILE $DIRS
else
  i=$(date +"%Hh%Mm%Ss")
  FILE="fs-i-$NOW-$i.tar.gz"
  tar -g $INCFILE -zcvf $BACKUP/$FILE $DIRS
fi

# Creating MySQL Backup #
# Get all databases names
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
 FILE=$BACKUP/mysql-$db.$NOW-$(date +"%T").gz
 $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done

# Transfer backup using FTP #
# Initiate FTP backup via ncftp
ncftp -u"$FTPU" -p"$FTPP" $FTPS<<EOF
mkdir $FTPD
mkdir $FTPD/$NOW
cd $FTPD/$NOW
lcd $BACKUP
mput *
quit
EOF

# Check if the FTP backup was successful #
if [ "$?" == "0" ]; then
 rm -f $BACKUP/*
else
 T=/tmp/backup.fail
 echo "Date: $(date)">$T
 echo "Hostname: $(hostname)" >>$T
 echo "Backup failed" >>$T
 # Send notification email if backup fails #
 mail  -s "BACKUP FAILED" "$EMAILID" <$T
 rm -f $T
fi
# All done, have fun :) #
