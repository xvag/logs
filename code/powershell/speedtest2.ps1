#FILE TO DOWNLOAD
$downloadurl = "http://urltofile"
$UploadURL = "http://urltofile"

#SIZE OF SPECIFIED FILE IN MB (adjust this to match the size of your file in MB)
$size = 188

#PROXY DETAILS
#$proxy = "http://PROXY-SERVER:PORT"  #Comment out this line to not use a proxy

#___________________________________________________________________

#WHERE TO STORE DOWNLOADED FILE
$documents = [Environment]::GetFolderPath("MyDocuments")
$localfile = "$documents/last-180.zip"


#RUN DOWNLOAD
$downloadstart_time = Get-Date
#$WebClientProxy = New-Object System.Net.WebProxy($proxy,$true)  #Comment out this line to not use a proxy
$webclient = New-Object System.Net.WebClient
#$webclient.proxy = $WebClientProxy  #Comment out this line to not use a proxy
$webclient.DownloadFile($downloadurl, $localfile)

#CALCULATE DOWNLOAD SPEED
$downloadtimetaken = $((Get-Date).Subtract($downloadstart_time).Seconds)
$downloadspeed = ($size / $downloadtimetaken)*8
Write-Output "Time taken: $downloadtimetaken second(s)   |   Download Speed: $downloadspeed mbps"

#___________________________________________________________________

# #RUN UPLOAD
# $uploadstart_time = Get-Date
# $webclient.UploadFile($UploadURL, $localfile) > $null;
#
# #CALCULATE UPLOAD SPEED
# $uploadtimetaken = $((Get-Date).Subtract($uploadstart_time).Seconds)
# $uploadspeed = ($size / $uploadtimetaken) * 8
# Write-Output "Time taken: $uploadtimetaken second(s)   |   Upload Speed: $uploadspeed mbps"

#___________________________________________________________________

#DELETE TEST DOWNLOAD FILE
Remove-Item -path $localfile
