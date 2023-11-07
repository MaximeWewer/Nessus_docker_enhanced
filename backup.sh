#!/bin/bash

# Backup Nessus with CLI : nessus = container name ; nessus-backup = filename of backup
docker exec -d nessus /opt/nessus/sbin/nessuscli backup --create nessus-backup

# Backup directory
DIR=$(dirname $(readlink -f $0))
backup_directory="$DIR/opt+nessus/var/nessus"

# Git directory
local_git_directory="$DIR/your_project"                             # Change with your repo name

# Check if the Git directory exist
if [ ! -d "$local_git_directory/.git" ]; then
    git clone https://TOKEN@github.com/git_user/your_project.git    # Change TOKEN value and GIT repo
    if [ ! -d "$local_git_directory/.gitignore" ]; then
        cd $local_git_directory
        echo !nessus-backup_*.tar.gz >> .gitignore
        git add .gitignore
    fi
fi

# Remove olds backup - Get previous backups in commits history 
# We keep locally only the last backup
rm -r "$local_git_directory/*"

# Browse through the backup files in the directory
for backup_file in "$backup_directory/nessus-backup"*.tar.gz; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$backup_file" .tar.gz)
    # Extract the timestamp from the file name
    timestamp=$(echo "$base_name" | awk -F_ '{print $2}')
    # Convert the timestamp into a human-readable date
    readable_date=$(date -u -d "@$timestamp" +"%Y-%m-%dT%H-%M-%S")
    # New file name with the human-readable date
    new_name="${base_name%_*}_${readable_date}.tar.gz"
    # Rename the file
    mv "$backup_file" "$DIR/your_project/$new_name"                 # Change with your repo name

    # Push the backup
    cd "$local_git_directory"
    git add .
    git commit -m "Backup of $readable_date"
    git push -u origin main --force
done