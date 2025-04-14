#!/bin/bash

# Configuration
DB_TYPE="mysql"  
DB_USER="nishitha"
DB_PASS="abc@123"
DB_NAME="my_database"
BACKUP_DIR="/home/nishitha/backups"   # select the path from your end   
REMOTE_STORAGE="nishitha@192.168.1.49:/home/nishitha/backups/" # select the path from your end 
DATE=$(date +'%Y%m%d_%H%M%S')
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"

mkdir -p "$BACKUP_DIR"

# Start MySQL backup
echo "Starting MySQL backup..."
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$BACKUP_FILE"

# Checking whether the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
    
    # SCP command to copy the backup file to remote server
    scp -o StrictHostKeyChecking=no "$BACKUP_FILE" "$REMOTE_STORAGE"
    
    if [ $? -eq 0 ]; then
        echo "File copied to remote server successfully."
    else
        echo "Failed to copy file to remote server."
    fi
else
    echo "MySQL backup failed."
fi

# If the first argument is "restore", restore the database
if [ "$1" == "restore" ]; then
    echo "Starting MySQL restore..."
    gunzip < "$2" | mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"
    if [ $? -eq 0 ]; then
        echo "Restore successful from $2"
    else
        echo "Restore failed."
    fi
    exit 0
fi
