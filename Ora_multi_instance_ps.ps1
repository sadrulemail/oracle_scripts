<# 
Author: Sadrul
Linkedin Profile:https://www.linkedin.com/in/sadrulalom/
Date: 11 August 2023
#>  

#Install-Module -Name Posh-SSH

#close all active sessions
foreach ($sid in (Get-SSHSession | select SessionId))
{
    Remove-SSHSession -SessionId $sid.SessionId
}

#List all host
$HostList = @(
        "SRV1.LearnWithSadrul.com"
        "SRV2.LearnWithSadrul.com"
        "SRV3.LearnWithSadrul.com"
        )
foreach($hostname in $HostList) {

write-host "***************Start Working on HOST :"$hostname "*****************" -ForegroundColor Green 
$HOST_NAME = $hostname
#$secpasswd = ConvertTo-SecureString "LearnWithSadrul!" -AsPlainText -Force
#$Creds = New-Object System.Management.Automation.PSCredential("LearnWithSadrul\salom", $secpasswd)
$Creds = Get-Crediential
$s_details = New-SSHSession -ComputerName $HOST_NAME -Credential $Creds -AcceptKey
$s_id = $s_details.SessionId;

$RetVal = Invoke-SSHCommand -SessionId $s_id -Command "ps -ef|grep smon"

$CharArray =$RetVal.Output.Split(" ")

foreach ($str in $CharArray) {
    if ($str.StartsWith("ora_smon")) {
        $ORA_SID = $str.replace("ora_smon_","").Trim();
        #$ORA_SID
        
        write-host "***************Start Working on SID:/"$ORA_SID "/*****************" -ForegroundColor Green

        $SSHStream = New-SSHShellStream -Index 0
        $ORA_Script="CREATE USER sadrul IDENTIFIED BY LearnWithSadrul;"
        
        $commandList = @(
        "sudo su -s /bin/bash oracle`n"
        "cd /home/oracle`n"
        "source .ora.env`n"
        "export ORACLE_SID=$ORA_SID`n"
        "sqlplus / as sysdba`n"
        "$ORA_Script`n"
        "commit;`n"
        "exit`n"
        )
        #$commandList
        foreach ($command in  $commandList) {
            #$command
            $SSHStream.write($command)            
            Start-Sleep 1
        }
         $SSHStream.Read();
         $SSHStream.Close();
    write-host "************End Working on SID:/"$ORA_SID"/***************" -ForegroundColor Green
    }

}

#close session
Remove-SSHSession -SessionId $s_id
write-host "***************End Working on HOST :"$hostname "*****************" -ForegroundColor Green 
}

