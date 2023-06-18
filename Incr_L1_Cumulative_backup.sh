#!/bin/bash

: '
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 16 MAY 2023
'

ROOT_BACKUP_PATH="/u01/app/backup/$(hostname)"
#echo $ROOT_BACKUP_PATH

BK_DATE=$(date +%Y%m%d_%H%M%S)

if [ ! -d "$ROOT_BACKUP_PATH" ]; then
    mkdir -p "$ROOT_BACKUP_PATH"
fi

retention_days=3;

find ${ROOT_BACKUP_PATH} -type f -mtime +${retention_days} -name '$(hostname)_${ORACLE_SID}_*.bkl1cu' -execdir rm -- '{}' \;

find ${ROOT_BACKUP_PATH} -type f -mtime +${retention_days} -name '${ORACLE_SID}_INCR1CU_*.log' -execdir rm -- '{}' \;


rman target / log=$ROOT_BACKUP_PATH/${ORACLE_SID}_INCR1CU_${BK_DATE}.log << EOF
run
{
ALLOCATE CHANNEL CH1 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_L1CU_%T_%s_%p_%U.bkl1cu';
#ALLOCATE CHANNEL CH2 DEVICE TYPE DISK FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_L1CU_%T_%s_%p_%U.bkl1cu';
CROSSCHECK BACKUP;
DELETE NOPROMPT OBSOLETE;
BACKUP AS COMPRESSED BACKUPSET tag 'INCR1_DB' INCREMENTAL LEVEL=1 CUMULATIVE DATABASE;
BACKUP CURRENT CONTROLFILE TAG 'INCR1_CTL' FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_L1_%T_%U.bkctll1';
BACKUP SPFILE TAG 'INCR1_SPFILE' FORMAT '${ROOT_BACKUP_PATH}/$(hostname)_%d_L1_%T_%U.bkspl1';
RELEASE CHANNEL CH1;
#RELEASE CHANNEL CH2;
}
EOF