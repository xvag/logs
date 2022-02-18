#Script to download and install Definitions from the SEPM
#V0.1 by Zebbelin for Symantec Community

#Needs to be modified for each environment:
$SEPM 		= "SEPM.mycomany.local"
$GoupID		= "5A176F310AF06355010E3A00D3B0626F"
$outbox 	= "\Outbox$"
$content	= "\Content$"


#Do not change any line below!!!!

#Environment for File Download
[void][reflection.assembly]::LoadWithPartialName("Microsoft.VisualBasic")
$object = New-Object Microsoft.VisualBasic.Devices.Network

#Build Variables:
$TempFolder 		= $env:TEMP + "\SEPtemp\"
$Index2 			= "\\" + $SEPM + $outbox + "\agent\" + $GoupID + "\index2.dax"
If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {$DefPath = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\InstalledApps\"} else {$DefPath = Get-ItemProperty "HKLM:\SOFTWARE\Symantec\Symantec Endpoint Protection\InstalledApps\"}
If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {$VirusDefinitions	= "{07B590B3-9282-482f-BBAA-6D515D385869}"} else {$VirusDefinitions	="{535CB6A4-441F-4e8a-A897-804CD859100E}"}
$SubmissionControl 	= "{B6DC6C8F-46FA-40c7-A806-B669BE1D2D19}"
$ProActiveThreat 	= "{D6AEBC07-D833-485f-9723-6C908D37F806}"
$NetworkThreat 		= "{55DE35DC-862A-44c9-8A2B-3EF451665D0A}"
$IronRevocation		= "{810D5A61-809F-49c2-BD75-177F0647D2BA}"
$IronWhitelist 		= "{EDBD3BD0-8395-4d4d-BAC9-19DD32EF4758}"

#Functions
Function DownloadDefs ($ID)
{
$Path 					= "\\" + $SEPM + $content + "\" + $ID
$Revision 				= Get-ChildItem $Path | Select-Object -Last 1
$Script:DownloadURL 	=  "http://" + $SEPM + ":8014/content/" + $ID + "/" + $Revision + "/full.zip"
$SCRIPT:DownloadPATH	= $TempFolder + $ID + "\" + $Revision + "\full.zip"
$SCRIPT:object.DownloadFile($DownloadURL, $DownloadPATH, "", "", $true, 10000, $true, "DoNothing")
}
Function DownloadIndex
{
$File= $TempFolder + "\index2.dax"
$SCRIPT:object.DownloadFile($Index2, $File , "", "", $true, 10000, $true, "DoNothing")
}
Function InstallDefs
{
Foreach ($Line in Get-ChildItem $TempFolder -Name) {
$Source = $TempFolder + $Line
$Destination = $DefPath.SEPAppDataDir + "inbox\" +$Line 
Move-Item -Path $Source -Destination $Destination -Force
	}
}

#Exectuion Sequence:
DownloadDefs $VirusDefinitions
DownloadDefs $SubmissionControl
DownloadDefs $ProActiveThreat 
DownloadDefs $NetworkThreat 
DownloadDefs $IronRevocation
DownloadDefs $IronWhitelist
DownloadIndex

InstallDefs