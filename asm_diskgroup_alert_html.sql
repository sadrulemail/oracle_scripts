--**********************************************
--** Author:Sadrul
--** Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
--** Date: 14 June 2023
--**********************************************

-- pl/sql code
DECLARE 
    html_scripts VARCHAR2(5000) :='';
    warning_threshold integer :=15;
    critical_threshold integer :=10;
    row_count integer :=0;

begin
	select count(name) into row_count from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold;
	if (row_count>0)
	then
		html_scripts := '<html><style>table, th, td {border:1px solid black;}</style>';
		html_scripts := html_scripts||'<br/><br/><table><tr><th>Disk Name</th><th>Total GB</th><th>Available GB</th><th>PTC_FREE</th>';


		for i in (select name,round(total_mb/1024,2) total_gb,
				round(free_mb/1024,2) free_gb,round((free_mb/total_mb)*100,2) 
				ptc_free from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold)

		   loop
			  html_scripts :=html_scripts||'<tr><td>'||i.name||'</td><td align="right">'||i.total_gb||'</td><td align="right">'||i.free_gb|| 
				case	when i.ptc_free<=warning_threshold and i.ptc_free>critical_threshold then 
							'</td><td align="right" bgcolor="yellow">'|| i.ptc_free||'</td></tr>'
						when i.ptc_free<=critical_threshold then
							'</td><td align="right" bgcolor="red">'|| i.ptc_free||'</td></tr>'
						else 
							'</td><td align="right">'|| i.ptc_free||'</td></tr>' 
				end;
		   end loop;
		html_scripts :=html_scripts||'</table>'; --table end
		html_scripts :=html_scripts||'</html>'; -- html end
   end if;
   dbms_output.Put_line(html_scripts);
end;


-- pl/sql FUNCTION
CREATE OR REPLACE FUNCTION ofunc_get_asm_disk_info_html
RETURN VARCHAR2
AS
	html_scripts VARCHAR2(5000) :='';
	warning_threshold integer :=15;
	critical_threshold integer :=10;
	row_count integer :=0;
begin
	select count(name) into row_count from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold;
	if (row_count>0)
	then
		html_scripts := '<html><style>table, th, td {border:1px solid black;}</style>';
		html_scripts := html_scripts||'<br/><br/><table><tr><th>Disk Name</th><th>Total GB</th><th>Available GB</th><th>PTC_FREE</th>';


		for i in (select name,round(total_mb/1024,2) total_gb,
					round(free_mb/1024,2) free_gb,round((free_mb/total_mb)*100,2) 
					ptc_free from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold)
		loop
			html_scripts :=html_scripts||'<tr><td>'||i.name||'</td><td align="right">'||i.total_gb||'</td><td align="right">'||i.free_gb|| 
			case when i.ptc_free<=warning_threshold and i.ptc_free>critical_threshold then 
					'</td><td align="right" bgcolor="yellow">'|| i.ptc_free||'</td></tr>'
				when i.ptc_free<=critical_threshold then
					'</td><td align="right" bgcolor="red">'|| i.ptc_free||'</td></tr>'
				else 
					'</td><td align="right">'|| i.ptc_free||'</td></tr>' 
			end;
		end loop;
		html_scripts :=html_scripts||'</table>'; --table end
		html_scripts :=html_scripts||'</html>'; -- html end

	--dbms_output.Put_line(html_scripts);
	end if;
return html_scripts;
end;

--execute pl/sql function
--select get_asm_disk_info_html from dual;

declare html_s varchar2(5000);
BEGIN
    html_s := ofunc_get_asm_disk_info_html();
    DBMS_OUTPUT.PUT_LINE(html_s);
END;


-- pl/sql PROCEDURE

CREATE OR REPLACE PROCEDURE oproc_get_asm_disk_info_html
AS
	html_scripts VARCHAR2(5000) :='';
	warning_threshold integer :=100;
	critical_threshold integer :=90;
	row_count integer :=0;
begin
	select count(name) into row_count from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold;
	if (row_count>0)
	then
		html_scripts := '<html><style>table, th, td {border:1px solid black;}</style>';
		html_scripts := html_scripts||'<br/><br/><table><tr><th>Disk Name</th><th>Total GB</th><th>Available GB</th><th>PTC_FREE</th>';


		for i in (select name,round(total_mb/1024,2) total_gb,
					round(free_mb/1024,2) free_gb,round((free_mb/total_mb)*100,2) 
					ptc_free from v$asm_diskgroup where round((free_mb/total_mb)*100,2)<=warning_threshold)
		loop
			html_scripts :=html_scripts||'<tr><td>'||i.name||'</td><td align="right">'||i.total_gb||'</td><td align="right">'||i.free_gb|| 
			case when i.ptc_free<=warning_threshold and i.ptc_free>critical_threshold then 
					'</td><td align="right" bgcolor="yellow">'|| i.ptc_free||'</td></tr>'
				when i.ptc_free<=critical_threshold then
					'</td><td align="right" bgcolor="red">'|| i.ptc_free||'</td></tr>'
				else 
					'</td><td align="right">'|| i.ptc_free||'</td></tr>' 
			end;
		end loop;
		html_scripts :=html_scripts||'</table>'; --table end
		html_scripts :=html_scripts||'</html>'; -- html end

	--dbms_output.Put_line(html_scripts);
	end if;
dbms_output.Put_line(html_scripts);
end;

-- exe procedure
EXECUTE oproc_get_asm_disk_info_html;
