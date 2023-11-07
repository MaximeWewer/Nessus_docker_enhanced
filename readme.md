# Nessus docker enhanced

Nessus scanner is a vulnerability scanner, more infos [here](https://www.tenable.com/products/nessus/nessus-professional).

## Features
- Expose volumes of Nessus
- Restore Nessus backup since backup file
- Create scheduled Nessus backup
- Push backup to remote Git

## Before build
- Clone repo
- Change values in ```docker-compse.yml```
- Change values in ```backup.sh```

## Usage
- For the first start : ```docker compose up --build -d```
- After the first start : ```docker compose up -d```
- Access ```https://localhost:8834```
- Schedule backup with CRON task of ```backup.sh```

##### Thank you Etienne.C for your work !
