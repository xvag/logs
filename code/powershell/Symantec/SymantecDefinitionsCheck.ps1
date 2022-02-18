###################################################################
## Check Symantec Endpoint Protection Antivirus Definition Dates ##
## v1.1 														 ##
## Matt Hansen // 01-06-2017									 ##
## https://www.thetechl33t.com 									 ##
###################################################################

#Set Variables
$hostname = hostname
$7daysago = (get-date).AddDays(-7)
$key = 'HKLM:SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion\SharedDefs'

#Test for registry key path and execute if neccessary
if (test-path -path $key) {
	Write-Host "$hostname, $7daysago"
	Write-Host "Installed"

$path = (Get-ItemProperty -Path $key -Name DEFWATCH_10).DEFWATCH_10
$writetime = [datetime](Get-ItemProperty -Path $path -Name LastWriteTime).lastwritetime
#Write-Host A min ago was $7daysago. DEFs was last written at $writetime

if ($writetime -lt $7daysago)
{Write-host "You have old defs"
Write-EventLog -LogName "Application" -Source "Symantec Antivirus" -EventId "7076" -EntryType "Warning" -Message "Symantec Definitions are older than 7 days. Last update time is was $writetime"
$notify = "yes"
}

if ($writetime -gt $7daysago)
{Write-host "You have current defs"
Write-EventLog -LogName "Application" -Source "Symantec Antivirus" -EventId "7077" -EntryType "Information" -Message "Symantec Definitions are current within 7 days. Last update time is was $writetime"
$notify = "no"

}

#Email Notify
if ($notify -eq "yes")
{
$param = @{
SmtpServer = "smtpserver@company.local"
Port = 25
UseSsl = $false
#Credential = "you@gmail.com"
From = "SymantecDefChecks@mcompany.local"
To = "administrator@company.local"
Subject = "Symantec Defintions Out-of-Date on $hostname"
Body = "Symantec Definitions are older than 7 days. Last update time is was $writetime on $hostname"
}
Send-MailMessage @param
#write-host "Email Sent"
}

}
else {
	Write-Host "$hostname $7daysago"
	Write-host "Not installed"
}
