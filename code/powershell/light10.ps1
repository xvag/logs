<#
Lighten Windows 10
1. install ADK(select only dism): http://go.microsoft.com/fwlink/p/?LinkId=526740
2. enable script execution: set-executionpolicy remotesigned
3. run the script: ./light10.ps1
#>

#dism /online /get-packages

#dism /online /get-intl

#dism /online /get-features

dism /online /disable-feature /featurename:LegacyComponents  /remove
dism /online /disable-feature /featurename:DirectPlay /remove
dism /online /disable-feature /featurename:SimpleTCP /remove
dism /online /disable-feature /featurename:SNMP /remove
dism /online /disable-feature /featurename:WMISnmpProvider /remove
dism /online /disable-feature /featurename:Windows-Identity-Foundation /remove
dism /online /disable-feature /featurename:Internet-Explorer-Optional-amd64 /remove
dism /online /disable-feature /featurename:NetFx3 /remove
dism /online /disable-feature /featurename:IIS-WebServerRole /remove
dism /online /disable-feature /featurename:IIS-WebServer /remove
dism /online /disable-feature /featurename:IIS-CommonHttpFeatures /remove
dism /online /disable-feature /featurename:IIS-HttpErrors /remove
dism /online /disable-feature /featurename:IIS-HttpRedirect /remove
dism /online /disable-feature /featurename:IIS-ApplicationDevelopment /remove
dism /online /disable-feature /featurename:IIS-NetFxExtensibility /remove
dism /online /disable-feature /featurename:IIS-NetFxExtensibility45 /remove
dism /online /disable-feature /featurename:IIS-HealthAndDiagnostics /remove
dism /online /disable-feature /featurename:IIS-HttpLogging /remove
dism /online /disable-feature /featurename:IIS-LoggingLibraries /remove
dism /online /disable-feature /featurename:IIS-RequestMonitor /remove
dism /online /disable-feature /featurename:IIS-HttpTracing /remove
dism /online /disable-feature /featurename:IIS-Security /remove
dism /online /disable-feature /featurename:IIS-URLAuthorization /remove
dism /online /disable-feature /featurename:IIS-RequestFiltering /remove
dism /online /disable-feature /featurename:IIS-IPSecurity /remove
dism /online /disable-feature /featurename:IIS-Performance /remove
dism /online /disable-feature /featurename:IIS-HttpCompressionDynamic /remove
dism /online /disable-feature /featurename:IIS-WebServerManagementTools /remove
dism /online /disable-feature /featurename:IIS-ManagementScriptingTools /remove
dism /online /disable-feature /featurename:IIS-IIS6ManagementCompatibility /remove
dism /online /disable-feature /featurename:IIS-Metabase /remove
dism /online /disable-feature /featurename:WAS-WindowsActivationService /remove
dism /online /disable-feature /featurename:WAS-ProcessModel /remove
dism /online /disable-feature /featurename:WAS-NetFxEnvironment /remove
dism /online /disable-feature /featurename:WAS-ConfigurationAPI /remove
dism /online /disable-feature /featurename:IIS-HostableWebCore /remove
dism /online /disable-feature /featurename:WCF-HTTP-Activation /remove
dism /online /disable-feature /featurename:WCF-NonHTTP-Activation /remove
dism /online /disable-feature /featurename:WCF-HTTP-Activation45 /remove
dism /online /disable-feature /featurename:WCF-TCP-Activation45 /remove
dism /online /disable-feature /featurename:WCF-Pipe-Activation45 /remove
dism /online /disable-feature /featurename:WCF-MSMQ-Activation45 /remove
dism /online /disable-feature /featurename:IIS-CertProvider /remove
dism /online /disable-feature /featurename:IIS-WindowsAuthentication /remove
dism /online /disable-feature /featurename:IIS-DigestAuthentication /remove
dism /online /disable-feature /featurename:IIS-ClientCertificateMappingAuthentication /remove
dism /online /disable-feature /featurename:IIS-IISCertificateMappingAuthentication /remove
dism /online /disable-feature /featurename:IIS-ODBCLogging /remove
dism /online /disable-feature /featurename:IIS-StaticContent /remove
dism /online /disable-feature /featurename:IIS-DefaultDocument /remove
dism /online /disable-feature /featurename:IIS-DirectoryBrowsing /remove
dism /online /disable-feature /featurename:IIS-WebDAV /remove
dism /online /disable-feature /featurename:IIS-WebSockets /remove
dism /online /disable-feature /featurename:IIS-ApplicationInit /remove
dism /online /disable-feature /featurename:IIS-ASPNET /remove
dism /online /disable-feature /featurename:IIS-ASPNET45 /remove
dism /online /disable-feature /featurename:IIS-ASP /remove
dism /online /disable-feature /featurename:IIS-CGI /remove
dism /online /disable-feature /featurename:IIS-ISAPIExtensions /remove
dism /online /disable-feature /featurename:IIS-ISAPIFilter /remove
dism /online /disable-feature /featurename:IIS-ServerSideIncludes /remove
dism /online /disable-feature /featurename:IIS-CustomLogging /remove
dism /online /disable-feature /featurename:IIS-BasicAuthentication /remove
dism /online /disable-feature /featurename:IIS-HttpCompressionStatic /remove
dism /online /disable-feature /featurename:IIS-ManagementConsole /remove
dism /online /disable-feature /featurename:IIS-ManagementService /remove
dism /online /disable-feature /featurename:IIS-WMICompatibility /remove
dism /online /disable-feature /featurename:IIS-LegacyScripts /remove
dism /online /disable-feature /featurename:IIS-LegacySnapIn /remove
dism /online /disable-feature /featurename:IIS-FTPServer /remove
dism /online /disable-feature /featurename:IIS-FTPSvc /remove
dism /online /disable-feature /featurename:IIS-FTPExtensibility /remove
dism /online /disable-feature /featurename:MSMQ-Container /remove
dism /online /disable-feature /featurename:MSMQ-Server /remove
dism /online /disable-feature /featurename:MSMQ-Triggers /remove
dism /online /disable-feature /featurename:MSMQ-ADIntegration /remove
dism /online /disable-feature /featurename:MSMQ-HTTP /remove
dism /online /disable-feature /featurename:MSMQ-Multicast /remove
dism /online /disable-feature /featurename:MSMQ-DCOMProxy /remove
dism /online /disable-feature /featurename:NetFx4Extended-ASPNET45 /remove
dism /online /disable-feature /featurename:WindowsMediaPlayer /remove
dism /online /disable-feature /featurename:RasRip /remove
dism /online /disable-feature /featurename:TelnetClient /remove
dism /online /disable-feature /featurename:TFTP /remove
dism /online /disable-feature /featurename:Printing-Foundation-LPRPortMonitor /remove
dism /online /disable-feature /featurename:Printing-Foundation-LPDPrintService /remove
dism /online /disable-feature /featurename:FaxServicesClientPackage /remove
dism /online /disable-feature /featurename:ScanManagementConsole /remove
dism /online /disable-feature /featurename:DirectoryServices-ADAM-Client /remove
dism /online /disable-feature /featurename:ServicesForNFS-ClientOnly /remove
dism /online /disable-feature /featurename:ClientForNFS-Infrastructure /remove
dism /online /disable-feature /featurename:NFS-Administration /remove
dism /online /disable-feature /featurename:RasCMAK /remove
dism /online /disable-feature /featurename:TIFFIFilter /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V-Tools-All /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V-Services /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V-Hypervisor /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V-Management-Clients /remove
dism /online /disable-feature /featurename:Microsoft-Hyper-V-Management-PowerShell /remove
dism /online /disable-feature /featurename:IsolatedUserMode /remove
dism /online /disable-feature /featurename:Client-EmbeddedShellLauncher /remove
dism /online /disable-feature /featurename:Client-EmbeddedBootExp /remove
dism /online /disable-feature /featurename:Client-EmbeddedLogon /remove
dism /online /disable-feature /featurename:Client-UnifiedWriteFilter /remove
dism /online /disable-feature /featurename:MultiPoint-Connector /remove

#Dism /online /Get-ProvisionedAppxPackages

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.3DBuilder_2015.624.2254.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.BingFinance_10004.3.193.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.BingNews_10004.3.193.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.BingSports_10004.3.193.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.BingWeather_10004.3.193.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.Getstarted_2015.622.1108.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.MicrosoftOfficeHub_2015.4218.23751.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.MicrosoftSolitaireCollection_3.1.6103.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.Office.OneNote_2015.4201.10091.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.People_2015.627.626.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.SkypeApp_3.2.1.0_neutral_~_kzf8qxf38zg5c

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.WindowsAlarms_2015.619.10.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.WindowsCamera_2015.612.1501.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.WindowsMaps_2015.619.213.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.WindowsSoundRecorder_2015.615.1606.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.XboxApp_2015.617.130.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.ZuneMusic_2019.6.10841.0_neutral_~_8wekyb3d8bbwe

Dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.ZuneVideo_2019.6.10811.0_neutral_~_8wekyb3d8bbwe
