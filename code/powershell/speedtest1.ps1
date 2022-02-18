#Replace the Download URL to where you've uploaded the ZIP file yourself. We will only download this file once. 
#Latest version can be found at: https://www.speedtest.net/nl/apps/cli
$DownloadURL = "https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-win64.zip"
$DownloadLocation = "$($Env:ProgramData)\SpeedtestCLI"

try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) {
        new-item $DownloadLocation -ItemType Directory -force
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip"
        Expand-Archive "$($DownloadLocation)\speedtest.zip" -DestinationPath $DownloadLocation -Force
    } 
}
catch {  
    write-host "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"
    exit 1
}

$SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json --accept-license --accept-gdpr
Write-Host "Speedtest Results 1:", $SpeedtestResults
$SpeedtestResults | Out-File "$($DownloadLocation)\LastResults.txt" -Force
$SpeedtestResults = $SpeedtestResults | ConvertFrom-Json
Write-Host "Speedtest Results 2:", $SpeedtestResults
 
#creating object
[PSCustomObject]$SpeedtestObj = @{
    downloadspeed = [math]::Round($SpeedtestResults.download.bandwidth / 1000000 * 8, 2)
    uploadspeed   = [math]::Round($SpeedtestResults.upload.bandwidth / 1000000 * 8, 2)
    packetloss    = [math]::Round($SpeedtestResults.packetLoss)
    isp           = $SpeedtestResults.isp
    ExternalIP    = $SpeedtestResults.interface.externalIp
    InternalIP    = $SpeedtestResults.interface.internalIp
    UsedServer    = $SpeedtestResults.server.host
    ResultsURL    = $SpeedtestResults.result.url
    Jitter        = [math]::Round($SpeedtestResults.ping.jitter)
    Latency       = [math]::Round($SpeedtestResults.ping.latency)
}


Write-Host "Result URL:", $SpeedtestResults.result.url
Write-Host "ISP: ", $SpeedtestResults.isp
Write-Host "ExternalIP:", $SpeedtestResults.interface.externalIp
Write-Host "InternalIP:", $SpeedtestResults.interface.internalIp
Write-Host "Server Host:", $SpeedtestResults.server.host
Write-Host ""
$dl = [math]::Round($SpeedtestResults.download.bandwidth / 1000000 * 8, 2)
Write-Host "Download:", $dl
$ul = [math]::Round($SpeedtestResults.upload.bandwidth / 1000000 * 8, 2)
Write-Host "Upload:", $ul
$pl = [math]::Round($SpeedtestResults.packetLoss)
Write-Host "PacketLoss:", $pl
$j = [math]::Round($SpeedtestResults.ping.jitter)
Write-Host "Jitter:", $j
$l = [math]::Round($SpeedtestResults.ping.latency)
Write-Host "Ping Latency:", $l
Write-Host ""