#!/bin/bash

BACKUP_DIR=/data/backup-system
BACKUP_LAST_DT_FILE=last-backup

exec 1>&2

if [[ ! -d "$BACKUP_DIR"  ]] ; then
    echo "$0: BACKUP_DIR \"$BACKUP_DIR\" does not exist, exiting"
    exit 1
fi

BACKUP_DATETIME_CURR=`date '+%F_%H-%M-%S'`
[[ -n "$BACKUP_DATETIME_CURR" ]] || exit 2

echo "$0: BACKUP_DATETIME_CURR is $BACKUP_DATETIME_CURR"

BACKUP_DIR_CURR="$BACKUP_DIR/$BACKUP_DATETIME_CURR"
if [[ -d "$BACKUP_DIR_CURR" ]] ; then
    echo "$0: BACKUP_DIR_CURR \"$BACKUP_DIR_CURR\" already exists, exiting"
    exit 1
fi
mkdir "$BACKUP_DIR_CURR"

RSYNC_LOGFILE="$BACKUP_DIR/$BACKUP_DATETIME_CURR.log"

BACKUP_DATETIME_PREV=`cat "$BACKUP_DIR/$BACKUP_LAST_DT_FILE"`
BACKUP_DIR_PREV="$BACKUP_DIR/$BACKUP_DATETIME_PREV"
if [[ -n "$BACKUP_DATETIME_PREV" ]] ; then
    BACKUP_LINKDEST="--link-dest=\"$BACKUP_DIR_PREV\""
fi

echo "$0: my PID is $$"                                   > "$RSYNC_LOGFILE"
echo "$0: BACKUP_DATETIME_CURR is $BACKUP_DATETIME_CURR" >> "$RSYNC_LOGFILE"
echo "$0: BACKUP_DATETIME_PREV is $BACKUP_DATETIME_PREV" >> "$RSYNC_LOGFILE"

RSYNC_COMMAND="/usr/bin/rsync -aHAXS \
    --exclude={\"/data/*\",\"/old-system/*\",\"/swapfile\",\"/media/*\",\"/mnt/*\",\"/var/lib/lxcfs/*\",\"/dev/*\",\"/proc/*\",\"/sys/*\",\"/tmp/*\",\"/var/tmp/*\",\"/run/*\"} \
    $BACKUP_LINKDEST \
    / \"$BACKUP_DIR_CURR\" "

echo "$0: executing $RSYNC_COMMAND"
echo "$0: executing $RSYNC_COMMAND" >> "$RSYNC_LOGFILE"

eval $RSYNC_COMMAND >> "$RSYNC_LOGFILE" 2>&1 \
    || { echo "$0: rsync failed!" ; exit 3 ; }

echo $BACKUP_DATETIME_CURR > "$BACKUP_DIR/$BACKUP_LAST_DT_FILE"

echo "$0: backup $BACKUP_DATETIME_CURR successful!"
echo "$0: backup $BACKUP_DATETIME_CURR successful!" >> "$RSYNC_LOGFILE"

