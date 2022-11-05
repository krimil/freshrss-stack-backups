#!/bin/sh

BACKUP_DIR=/backups

#Databases
source .env
docker exec freshrss-db /bin/bash \
  -c "export PGPASSWORD=$FRESHRSS_DB_PASS \
  && pg_dump -U $FRESHRSS_DB_USER $FRESHRSS_DB_NAME" \
  | gzip -9 > $BACKUP_DIR/freshrss_db_$(date "+%F-%H%M%S").sql.gzip
  
# docker exec invidious-db /bin/bash \
#   -c "export PGPASSWORD=$INVIDIOUS_DB_PASS \
#   && pg_dump -U $INVIDIOUS_DB_USER $INVIDIOUS_DB_NAME" \
#   | gzip -9 > $BACKUP_DIR/invidious_db_$(date "+%F-%H%M%S").sql.gzip  


#Volumes
docker run --rm --volumes-from freshrss -v $(pwd):$BACKUP_DIR ubuntu tar zcvf $BACKUP_DIR/freshrss_config_$(date "+%F-%H%M%S").tar.gz /config


#Cleanup
find $BACKUP_DIR/* -mtime +$BACKUP_DAYS -exec rm {} \;

#Remote
REMOTE=$(rclone --config /config/rclone.conf listremotes | head -n 1)
rclone --config /config/rclone.conf sync $BACKUP_DIR $REMOTE$BACKUP_RCLONE_DEST
