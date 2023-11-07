#!/bin/bash

chmod a+rwx /tmp
chmod a+t /tmp

if [ ! -e "/opt/nessus/sbin/nessuscli" ]; then
    echo "Decompressing the Nessus file archive"
    tar xvzf /opt+nessus.tar.gz
    echo "Decompression completed"
fi

if [ $NESSUS_BACKUP_FILE == "" ] || [ $NESSUS_BACKUP_FILE == "NONE" ]; then
    echo "First installation"
    echo "Starting Nessus ..."
    supervisord -c /etc/supervisord.conf
    exit 0
fi

if [ ! -e "/home/nessus/.git" ] && [ $NESSUS_BACKUP_GIT != "" ]; then
    echo "Cloning the backup repository"
    git clone $NESSUS_BACKUP_GIT "/home/nessus"
    echo "Cloning completed"
fi

echo "Checking the existence of /home/nessus/$NESSUS_BACKUP_FILE"
if [ ! -e "/home/nessus/$NESSUS_BACKUP_FILE" ]; then
    echo "The file /home/nessus/$NESSUS_BACKUP_FILE does not exist!"
    echo "Stopping ..."
    exit 1
else
    echo "/home/nessus/$NESSUS_BACKUP_FILE exists."
fi

if md5sum -c token.md5 < "/home/nessus/$NESSUS_BACKUP_FILE" ; then
    echo "Archive already restored."
    echo "Starting Nessus ..."
    supervisord -c /etc/supervisord.conf
    exit 0
else
    # Removing files causing the error of the nessusd service already started
    rm -f "/opt/nessus/var/nessus/nessusd.pid" "/opt/nessus/var/nessus/nessus-service.pid"
    
    echo "Restoring the archive ..."
    if /opt/nessus/sbin/nessuscli backup --restore "/home/nessus/$NESSUS_BACKUP_FILE" ; then
        echo "Archive restored!"
        
        echo "Checking the backup user ..."
        MY_NESSUS_USER=$(/opt/nessus/sbin/nessuscli lsuser)

        echo "Checking the current user ..."
        if [ $MY_NESSUS_USER != $USERNAME ]; then
            echo "Error : Unable to modify the password for $USERNAME!"
            echo "The user of the restored backup is $MY_NESSUS_USER."
            echo "Please modify 'USERNAME' to match the backup to be restored. Stopping."
            exit 1
        fi

        echo "Creating the checksum ..."
        md5sum < "/home/nessus/$NESSUS_BACKUP_FILE" > "/home/nessus/token.md5"
        echo "Checksum created!"

        echo "Starting Nessus ..."
        supervisord -c /etc/supervisord.conf
        exit 0
    else
        echo "Restoration error... Stopping"
        exit 1
    fi
fi
