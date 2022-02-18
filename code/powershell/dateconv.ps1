# convert epoch time to human time
# use in sms xml files

function Convert-FromUnixDate($UnixDate) {
  [timezone]::CurrentTimeZone.ToLocalTime(([DateTime]'1/1/1970').AddMilliseconds($UnixDate))
}


$xmlfile = Read-Host -Prompt 'Enter xml filename'

New-Item .\conv-$xmlfile


$re = [regex]'\d{13}'
$callback = { Convert-FromUnixDate($args[0].Value) }

Get-Content -Path $xmlfile | ForEach-Object {
  $tmpstr = $re.Replace($_, $callback)
  Add-Content .\conv-$xmlfile "$tmpstr"
}

#Write-Host "File Converted. Press any key to exit..."
#$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")