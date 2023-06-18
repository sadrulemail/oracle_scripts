Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 16 June 2023


UTL_MAIL setup for ORACLE(before setup confirm that SRV have SMTP replay and ASK SMTP SRV NAME)
1. Check already setup or not
select object_name,object_type,owner from dba_objects where object_name in('UTL_MAIL','UTL_SMTP');
2. Connect as sysdba and execute for below
@$ORACLE_HOME/rdbms/admin/utlmail.sql
@$ORACLE_HOME/rdbms/admin/utlsmtp.sql
@$ORACLE_HOME/rdbms/admin/prvtmail.plb

2. grant execute permission to public
GRANT EXECUTE ON utl_mail TO PUBLIC;
GRANT EXECUTE ON utl_smtp TO PUBLIC;

3. set smtp server name for parameter
alter system set smtp_out_server='smtp-learnwithsadrul.com' scope=both;

4. create ACL
exec DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('sadrul_utl_mail.xml','Allow mail to be send','SADRUL', TRUE, 'connect');
commit;

5. Grant the connect and resource privilege
exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('sadrul_utl_mail.xml','SADRUL', TRUE, 'connect');
exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('sadrul_utl_mail.xml' ,'SADRUL', TRUE, 'resolve');
exec DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('sadrul_utl_mail.xml','*',25);
commit;
6. Test mail

BEGIN
  UTL_MAIL.send(sender     => 'lnx8@learnwithsadrul.com',
                recipients => 'sadrul.email@gmai.com',
                subject    => 'UTL_MAIL Test',
                message    => 'If you get this message it worked!');
END;
/

--HTML Test
DECLARE
  l_html VARCHAR2(32767);
begin
  l_html := '<html>
  <head>
  <title>Test HTML message</title>
  </head>
  <body>
  <p>This is a <b>HTML</b> <i>version</i> of the test message.</p>
  </body>
  </html>';

  UTL_MAIL.send(sender     => 'lnx8@learnwithsadrul.com',
                recipients => 'sadrul.email@gmai.com',
                subject    => 'UTL_MAIL HTML Test',
                message    => l_html,
                mime_type    => 'text/html');
END;
/


7. check access list;
select * from dba_network_acls;
select * from dba_network_acl_privileges;
