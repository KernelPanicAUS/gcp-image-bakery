$ErrorActionPreference = "Stop"

# Set-ExecutionPolicy Bypass -Scope Process -Force
Write-Output "+++ Disabling UAC… +++"

New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -PropertyType DWord -Value 0 -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output "+++ Installing Chocolatey… +++"
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Get-PackageSource
Write-Host 'Install-PackageProvider ...'
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Write-Host 'List Package sources ...'
Get-PackageSource

Write-Output "+++ Add PSGallery to trust store… +++"
Set-PSRepository "PSGallery" -InstallationPolicy Trusted -Verbose
Write-Output 'installing Windows Update module'
Install-Module PSWindowsUpdate -Confirm:$False -Force -Verbose
Write-Output 'downloading updates'
Get-WindowsUpdate -AcceptAll -Verbose
Write-Output 'installing updates'
Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
Write-Output 'install ComputerManagementDsc'
Install-Module -Name ComputerManagementDsc -Confirm:$False -Force
Write-Output 'install AuditPolicyDsc'
Install-Module -Name AuditPolicyDsc -Confirm:$False -Force
Write-Output 'install SecurityPolicyDsc'
Install-Module -Name SecurityPolicyDsc -Confirm:$False -Force

Write-Output 'install google agent'
(New-Object Net.WebClient).DownloadFile("https://repo.stackdriver.com/windows/StackdriverMonitoring-GCM-46.exe", "${env:UserProfile}\StackdriverMonitoring-GCM-46.exe")
& "${env:UserProfile}\StackdriverMonitoring-GCM-46.exe"

C:/scripts/CIS_WindowsServer2016_v110.ps1
C:/scripts/AuditPolicy_WindowsServer2016.ps1
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 2048
#winrm quickconfig
Start-DscConfiguration -Path .\CIS_WindowsServer2016_v110  -Force -Verbose -Wait
Start-DscConfiguration -Path .\AuditPolicy_WindowsServer2016  -Force -Verbose -Wait
