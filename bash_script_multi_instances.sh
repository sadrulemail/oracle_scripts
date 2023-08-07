#!/bin/bash

: '
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 7 August 2023
'

#HOSTS="srv1 srv2 srv3"

USERNAME=oracle
HOSTS="ORALNX88DGN2"
for HOSTNAME in ${HOSTS} ; do

if [ -f dbname_temp.txt ] ; then
    rm dbname_temp.txt
fi

sshpass -p 123 ssh ${USERNAME}@${HOSTNAME} ps -ef | grep smon >> dbname_temp.txt
	while read line; do
		IFS=' '
		read -a strarr <<< "$line"
		lastval=$(echo ${strarr[-1]} | tr 'ora_smon_' ' ')
		echo $lastval
		#${lastval//[[:blank:]]/}
		#sqlplus 'sys/123@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=${HOSTNAME})(Port=1521))(CONNECT_DATA=(SID=${lastval})))'
		
		#SCRIPT="cd /home/oracle;export ORACLE_SID=UATDB;export ORACLE_BASE=/app/oracle;export ORACLE_HOME=/app/oracle/product/19.0.0/db_home;export PATH=$PATH:$ORACLE_HOME/bin;sqlplus / as sysdba;select * from emp;exit;"
		#SCRIPT="cd /home/oracle;export ORACLE_SID=${lastval//[[:blank:]]/};export ORACLE_BASE=/app/oracle;export ORACLE_HOME=/app/oracle/product/19.0.0/db_home;export PATH=$PATH:$ORACLE_HOME/bin;sqlplus / as sysdba;"
		#SCRIPT="cd /home/oracle;export ORACLE_SID=${lastval//[[:blank:]]/};export ORACLE_BASE=/app/oracle;export ORACLE_HOME=/app/oracle/product/19.0.0/db_home;export PATH=$PATH:$ORACLE_HOME/bin;sqlplus / as sysdba >> EOF select name, open_mode from v\$database EOF exit;"
		SCRIPT="cd /home/oracle;export ORACLE_SID=${lastval//[[:blank:]]/};export ORACLE_BASE=/app/oracle;export ORACLE_HOME=/app/oracle/product/19.0.0/db_home;export PATH=$PATH:$ORACLE_HOME/bin;
		sqlplus / as sysdba << EOF 
		delete from emp; 
		commit;
		EXIT; 
		EOF"
		echo $SCRIPT		
		sshpass -p '123' ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTNAME}  ${SCRIPT}	
	done < dbname_temp.txt
done