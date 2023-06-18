#!/bin/bash

: '
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 16 June 2023
'

. /home/oracle/scripts/setEnv.sh

# FUNC to delete arch logs

del_arch_log () {
rman log=/home/oracle/scripts/delete_arch.log << EOF
connect target /
crosscheck archivelog all;
delete noprompt archivelog until time 'sysdate-3';
exit
EOF
}

#Main to call archive delete
echo "starting delete arch logs."
del_arch_log
echo "Deleted successfully."