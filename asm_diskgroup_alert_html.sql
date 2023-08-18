--**********************************************
--** Author:Sadrul
--** Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
--** Date: 14 June 2023
--**********************************************

create or replace PROCEDURE proc_get_asm_diskgroup_notification
AS
    html_scripts VARCHAR2(5000) :='';
	warning_threshold integer :=15;
	critical_threshold integer :=10;
	row_count integer :=0;
BEGIN
	select count(name) into row_count from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold;
	IF (row_count>0)
	THEN
		html_scripts := '<html><style>table, th, td {border:1px solid black;}</style>';
		html_scripts := html_scripts||'<br/><br/><table><tr><th>Disk Name</th><th>Total GB</th><th>Available GB</th><th>PTC_FREE</th>';

		FOR i IN (select name,round(total_mb/1024,2) total_gb,round(free_mb/1024,2) free_gb,round((free_mb/total_mb)*100,2) 
					ptc_free from v$asm_diskgroup)
		LOOP
			html_scripts :=html_scripts||'<tr><td>'||i.name||'</td><td align="right">'||i.total_gb||'</td><td align="right">'||i.free_gb|| 
			CASE WHEN i.ptc_free<=warning_threshold AND i.ptc_free>critical_threshold THEN 
					'</td><td align="right" bgcolor="yellow">'|| i.ptc_free||'</td></tr>'
				WHEN i.ptc_free<=critical_threshold THEN
					'</td><td align="right" bgcolor="red">'|| i.ptc_free||'</td></tr>'
				ELSE 
					'</td><td align="right">'|| i.ptc_free||'</td></tr>' 
			END;
		END LOOP;
		html_scripts :=html_scripts||'</table>'; --table end        
        html_scripts :=html_scripts|| '<br/><br/><b>Thank you,</b><br/><b>DBA Team</b>';
        html_scripts :=html_scripts||'</html>'; -- html end

        UTL_MAIL.send(sender     => SYS_CONTEXT ('USERENV', 'SERVER_HOST')||'@LearnWithSadrul.com',
            recipients => 'sadrul.email@gmail.com',
            subject    => 'ASM DiskGroup Space Notification ('||SYS_CONTEXT ('USERENV', 'SERVER_HOST')||'/'||SYS_CONTEXT('USERENV','INSTANCE_NAME')||')',
            message    => html_scripts,
            mime_type    => 'text/html');
    END IF;
END;
/

-- create program for job, it is the mail action
begin
  DBMS_SCHEDULER.create_program (
    program_name        => 'get_asm_diskgroup_notification_prog',
    program_type        => 'STORED_PROCEDURE',
    program_action      => 'proc_get_asm_diskgroup_notification',
    enabled             => true,
    comments            => 'ASM diskgrop notification based on free PTC');
end;
/
-- create schedule
begin
dbms_scheduler.create_schedule
(
schedule_name => 'Hourly_Interval_4',
start_date      => SYSTIMESTAMP,
repeat_interval => 'freq=hourly; interval=4; byminute=0; bysecond=0;',
comments => 'Hourly_Interval_4'
);
end;
/
-- create job
begin
dbms_scheduler.create_job
(
job_name => 'GET_ASM_DISKGROUP_NOTIFICATION_JOB',
program_name => 'get_asm_diskgroup_notification_prog',
schedule_name => 'Hourly_Interval_4',
comments => 'SEND MAIL ABOUT ASM DISK SPACE.',
enabled => TRUE
);
end;
/

-- add job fail notification
BEGIN
 DBMS_SCHEDULER.add_job_email_notification (
  job_name   =>  'GET_ASM_DISKGROUP_NOTIFICATION_JOB',
  recipients =>  'sadrul.email@gmail.com',
  events     =>  'JOB_FAILED');
END;
/
