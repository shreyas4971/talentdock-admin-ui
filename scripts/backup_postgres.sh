#!/bin/bash
# scripts/backup_postgres.sh
# Purpose: Daily automated PostgreSQL backup for TalentOS MVP
# Execution: Should be scheduled via cron (e.g., 0 2 * * * /app/scripts/backup_postgres.sh)

# Configuration
BACKUP_DIR="/var/backups/talentos"
RETENTION_DAYS=30
DB_CONTAINER="talentos-db-1"
DB_USER="talentos_user"
DB_NAME="talentos_db"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/talentos_${TIMESTAMP}.dump"

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting PostgreSQL Backup..."

# Execute dump inside the docker container
docker exec $DB_CONTAINER pg_dump -U $DB_USER -F c -d $DB_NAME -f /tmp/db.dump

# Copy out of the container to the host backup directory
docker cp $DB_CONTAINER:/tmp/db.dump "$BACKUP_FILE"

# Clean up container temp file
docker exec $DB_CONTAINER rm /tmp/db.dump

echo "[$(date)] Backup completed: $BACKUP_FILE"

# Enforce Retention Policy
echo "[$(date)] Pruning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "*.dump" -mtime +$RETENTION_DAYS -delete

echo "[$(date)] Pruning complete."
