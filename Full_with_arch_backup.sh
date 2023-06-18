#!/bin/bash

: '
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 15 APRIL 2023
Desc: this is usefull full DB migration, upgradation and non-prod environment where DB in no archivelog mode
'

ROOT_BACKUP_PATH="/u01/app/backup/$(hostname)"
#echo $ROOT_BACKUP_PATH

BK_DATE=$(date +%Y%m%d_%H%M%S)

if [ ! -d "$ROOT_BACKUP_PATH" ]; then
    mkdir -p "$ROOT_BACKUP_PATH"
fi

retention_days=10;

find ${ROOT_BACKUP_PATH} -type f -mtime +${retention_days} -name '$(hostname)_${ORACLE_SID}_*.bkfull' -execdir rm -- '{}' \;

find ${ROOT_BACKUP_PATH} -type f -mtime +${retention_days} -name '${ORACLE_SID}_FULL_*.log' -execdir rm -- '{}' \;

LOG_PATH="${ROOT_BACKUP_PATH}/${ORACLE_SID}_FULL_${BK_DATE}.log"

rman target / log=$LOG_PATH << EOF
run
{
ALLOCATE CHANNEL CH1 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%s_%p_%U.bkfull';
ALLOCATE CHANNEL CH2 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%s_%p_%U.bkfull';
ALLOCATE CHANNEL CH3 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%s_%p_%U.bkfull';
BACKUP FORCE AS COMPRESSED BACKUPSET tag 'FULL_DB' DATABASE PLUS ARCHIVELOG;
BACKUP CURRENT CONTROLFILE TAG 'FULL_CTL' FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%U.bkctlfull';
BACKUP SPFILE TAG 'FULL_SPFILE' FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%U.bkspfull';
RELEASE CHANNEL CH1;
RELEASE CHANNEL CH2;
RELEASE CHANNEL CH3;
}
EOF