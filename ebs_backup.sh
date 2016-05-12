#!/bin/bash

# Script to create daily snapshots and delete after 7 days
export AWS_ACCESS_KEY_ID="xx"
export AWS_SECRET_ACCESS_KEY="xxx"

BACKUP_CONFIG_FILE="/root/aws_backup/backup.conf"
touch $BACKUP_CONFIG_FILE

ORGEON_DISK1="vol-xxx"
ORGEON_DISK2="vol-xxx"

VIRGINIA_DISK1="vol-xx"
VIRGINIA_DISK2="vol-xx"

# Delete Backups
DELETE_BACKUP()
{
 if [[ -f $BACKUP_CONFIG_FILE ]]; then
	  DEL_COUNT=`grep $1 $BACKUP_CONFIG_FILE | wc -l`
	  if [ $DEL_COUNT -gt "7" ]; then
		DEL_NAME=`grep $1 $BACKUP_CONFIG_FILE | head -n1 | awk -F ":" '{print $2}'`
		aws ec2 delete-snapshot --region $2 --snapshot-id $DEL_NAME
		echo "$SNAPID Deleted"
	  	sed -i "/$DEL_NAME/d" $BACKUP_CONFIG_FILE 
	  fi
 fi
}
# End Delete backups

CREATE_BACKUP()
{
 BKUP_NAME=$1_`date +%Y_%m_%d_T%H%M`
 aws ec2 create-snapshot --region $2 --description $BKUP_NAME --volume-id $1 > /tmp/snapshot.tmp
 SNAPID=`grep SnapshotId /tmp/snapshot.tmp | awk -F '"' '{print $4}'  `
 echo "$1:$SNAPID:$BKUP_NAME" >> $BACKUP_CONFIG_FILE
}

CREATE_BACKUP $ORGEON_DISK1 us-west-2
CREATE_BACKUP $ORGEON_DISK2 us-west-2
DELETE_BACKUP $ORGEON_DISK1 us-west-2
DELETE_BACKUP $ORGEON_DISK2 us-west-2

CREATE_BACKUP $VIRGINIA_DISK1 us-east-1
CREATE_BACKUP $VIRGINIA_DISK2 us-east-1
DELETE_BACKUP $VIRGINIA_DISK1 us-east-1
DELETE_BACKUP $VIRGINIA_DISK2 us-east-1
echo "" >> $BACKUP_CONFIG_FILE

exit 0

