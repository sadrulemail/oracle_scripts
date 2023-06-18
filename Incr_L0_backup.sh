#!/bin/bash

: '
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 16 June 2023
'

ROOT_BACKUP_PATH="/u01/app/backup/$(hostname)"
#echo $ROOT_BACKUP_PATH

BK_DATE=$(date +%Y%m%d_%H%M%S)

if [ ! -d "$ROOT_BACKUP_PATH" ]; then
    mkdir -p "$ROOT_BACKUP_PATH"
fi

rman target / log=$ROOT_BACKUP_PATH/${ORACLE_SID}_${BK_DATE}.log << EOF
run
{
ALLOCATE CHANNEL CH1 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%U.bkl0';
#ALLOCATE CHANNEL CH2 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%U.bkl0';
CROSSCHECK BACKUP;
DELETE NOPROMPT OBSOLETE;
BACKUP tag 'INCR0_DB' INCREMENTAL LEVEL=0 DATABASE;
BACKUP CURRENT CONTROLFILE TAG 'INCR0_CTL' FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%U.bkctllo';
BACKUP SPFILE TAG 'INCR0_SPFILE' FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_${BK_DATE}_%U.bksplo';
RELEASE CHANNEL CH1;
#RELEASE CHANNEL CH2;
}
EOF