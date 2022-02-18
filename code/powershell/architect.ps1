$ARCH=(gwmi -Query "Select OSArchitecture from Win32_OperatingSystem").OSArchitecture

If ($ARCH -eq "32-bit") {
	Write-Host "Install 32 bit version"
} 
Else {
	Write-Host "Install 64 bit version"
}

Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
