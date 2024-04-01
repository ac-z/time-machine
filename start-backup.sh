#!/bin/bash

# Default options
backup_name="$USERNAME@$HOSTNAME"
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
    exit 0
fi

# Set the name of the safety hash file
hash_file="${script_dir}/tm/_hashes"
# If the hash file exists, check it
if [ -f "$hash_file" ]; then
    sha256sum -c "$hash_file" --quiet
    if [ $? -ne 0 ]; then
        echo "The backup hash doesn't match. Currently backed-up files could be corrupted. Cannot continue."
        echo "Exiting..."
        exit 0
    else
        echo "Hash matches. Continuing..."
    fi
else
    echo "No hash file found. Continuing..."
fi

# And the logs directory
log_dir="$script_dir/tm/_logs"
mkdir -p "$log_dir"
# And the backup directory
backup_dir="$script_dir/tm/$backup_name"
mkdir -p "$backup_dir"
touch "$backup_dir/backup.marker"

# Ensure exclude.txt exists
exclude_file="$script_dir/exclude.txt"
if [ ! -f "$exclude_file" ]; then
    echo "No exclude.txt found. Exiting..."
    exit 0
fi

# Start the backup
echo "==> Starting backup..."
$tmbackup --log-dir "${log_dir}/" "${backup_target}/" "${backup_dir}/" $exclude_file

# Ensure the backup succeeded
if [ $? -ne 0 ]; then
    echo "Backup failed. Exiting..."
    exit 0
fi

# Create $hash_file file listing the hashes of every file in $script_dir/tm
echo "==> Creating hash file..."
find "$script_dir/tm" -type f -exec sha256sum {} \; > "$hash_file"

# Ensure the hash succeeded
if [ $? -ne 0 ]; then
    echo "Hashing failed. Exiting..."
    exit 0
fi

