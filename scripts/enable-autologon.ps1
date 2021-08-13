$ErrorActionPreference = "Stop"

If ([string]::IsNullOrEmpty($Env:ADMIN_PASSWORD)) { Throw "Env:ADMIN_PASSWORD must be set" }
Write-Output "Enabling AutoAdminLogon to allow packer's scheduled task created by elevated_user to run..."
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1 -type String
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUsername -Value $Env:UserName -type String
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "$Env:ADMIN_PASSWORD" -type String