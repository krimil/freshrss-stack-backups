#!/bin/sh

# cd /freshrss
source .env
docker exec freshrss-db /bin/bash \
  -c "export PGPASSWORD=$FRESHRSS_DB_PASS \
  && pg_dump -U $FRESHRSS_DB_USER $FRESHRSS_DB_NAME" \
  | gzip -9 > /backups/freshrss_$(date "+%F-%H%M%S").sql.gzip
  
# docker exec invidious-db /bin/bash \
#   -c "export PGPASSWORD=$INVIDIOUS_DB_PASS \
#   && pg_dump -U $INVIDIOUS_DB_USER $INVIDIOUS_DB_NAME" \
#   | gzip -9 > /backups/invidious_$(date "+%F-%H%M%S").sql.gzip  

# cd /

BACKUP_DIR=/backups
find $BACKUP_DIR/* -mtime +$BACKUP_DAYS -exec rm {} \;

REMOTE=$(rclone --config /config/rclone.conf listremotes | head -n 1)
rclone --config /config/rclone.conf sync $BACKUP_DIR $REMOTE$BACKUP_RCLONE_DEST
