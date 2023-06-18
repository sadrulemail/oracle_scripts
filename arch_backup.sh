#!/bin/bash

: '
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 25 MAY 2023
'

ROOT_BACKUP_PATH="/u01/app/backup/$(hostname)"
#echo $ROOT_BACKUP_PATH

BK_DATE=$(date +%Y%m%d_%H%M%S)

if [ ! -d "$ROOT_BACKUP_PATH" ]; then
    mkdir -p "$ROOT_BACKUP_PATH"
fi

rman target / log=$ROOT_BACKUP_PATH/${ORACLE_SID}_ARCHIVELOG_${BK_DATE}.log << EOF
run
{
ALLOCATE CHANNEL CH1 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_ARCH_%T_%e_%s_%p.alog';
CROSSCHECK ARCHIVELOG ALL;
DELETE EXPIRED ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL NOT BACKED UP 1 TIMES DELETE ALL INPUT;
RELEASE CHANNEL CH1;
}
EOF