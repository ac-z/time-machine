#!/bin/bash

# Default options
backup_name="$USER@$HOSTNAME"
backup_target="$HOME"
# Detect if in Android by checking $ANDROID_ROOT
if [ -n "$ANDROID_ROOT" ]; then
    backup_name="android"
    backup_target="/storage/emulated/0"
fi

# Obtain the full path of the script
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# "Time machine" backup script
tmbackup="./rsync-time-backup/rsync_tmbackup.sh"
# Exit if the backup script doesn't exist
if [ ! -f "$tmbackup" ]; then
    echo "Backup script not found. "
    exit 1
fi

# And the logs directory
log_dir="$script_dir/_backups/_logs"
mkdir -p "$log_dir"
# And the backup directory
backup_dir="$script_dir/_backups/$backup_name"
mkdir -p "$backup_dir"
touch "$backup_dir/backup.marker"

# Ensure exclude.txt exists
exclude_file="$script_dir/exclude.txt"
if [ ! -f "$exclude_file" ]; then
    echo "No exclude.txt found. Exiting..."
    exit 1
fi

# Start the backup
echo "==> Starting backup..."
$tmbackup --log-dir "${log_dir}/" "${backup_target}/" "${backup_dir}/" $exclude_file

# Ensure the backup succeeded
if [ $? -ne 0 ]; then
    echo "Backup failed. Exiting..."
    exit 1
else
    echo "Backup succeeded. Exiting..."
    exit 0
fi

