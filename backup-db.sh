#!/bin/sh

cd ~/docker/freshrss
source .env
docker exec postgres /bin/bash \
  -c "export PGPASSWORD=$FRESHRSS_DB_PASS \
  && pg_dump -U $FRESHRSS_DB_USER $FRESHRSS_DB_NAME" \
  | gzip -9 > /backups/backup_$(date "+%F-%H%M%S").sql.gzip
cd /

BACKUP_DIR=/backups
find $BACKUP_DIR/* -mtime +$BACKUP_DAYS -exec rm {} \;

REMOTE=$(rclone --config /config/rclone.conf listremotes | head -n 1)
rclone --config /config/rclone.conf sync $BACKUP_DIR $REMOTE$BACKUP_RCLONE_DEST
