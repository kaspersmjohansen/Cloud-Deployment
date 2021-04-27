$OSDCloudFolder = "D:\OSDCloud"
$OSDWallpaperFolder = $OSDCloudFolder + "\" + "wallpaper"

If (!(Test-Path -Path $OSDCloudFolder))
{
New-Item -Path $OSDCloudFolder -ItemType Directory -Verbose
}

Import-Module PowerShellGet -Force
Install-Module -Name OSD -force
New-OSDCloud.workspace -WorkspacePath $OSDCloudFolder

# Autopilot creds
$Autopilotcreds = Get-Credential
Install-module Microsoft.Graph -Force
Connect-MSGraph -Credential $Autopilotcreds
$Autopilotdisplayname = (Get-AutopilotProfile).displayname

# Autopilot configuration
Get-AutopilotProfile | Where-Object DisplayName -eq $Autopilotdisplayname | ConvertTo-AutopilotConfigurationJSON | Out-File -FilePath "$OSDCloudFolder\AutoPilot\Profiles\AutoPilotConfigurationFile.json" -Encoding ASCII

Edit-OSDCloud.winpe -WorkspacePath $OSDCloudFolder

# Create wallpaper folder and download wallpaper
If (!(Test-Path -Path "$OSDWallpaperFolder"))
{
New-Item -Path "$OSDWallpaperFolder" -ItemType Directory -Verbose
}
Invoke-WebRequest -Uri https://github.com/kaspersmjohansen/Cloud-Deployment/raw/main/wallpaper.jpg -OutFile "$OSDWallpaperFolder\wallpaper.jpg"

# Cloud drivers
# Edit-OSDCloud.winpe -CloudDriver Dell,Nutanix,VMware

# Your own drivers
# Edit-OSDCloud.winpe -DriverPath $OSDCloudFolder


# New-OSDCloud.template -WinRE -Language da-dk -SetAllIntl da-dk -SetInputLocale da-dk -verbose
New-OSDCloud.template -WinRE -SetInputLocale da-dk -verbose
#New-OSDCloud.workspace -workspacepath $OSDCloudFolder -Verbose

Edit-OSDCloud.winpe -workspacepath $OSDCloudFolder -WebPSScript https://raw.githubusercontent.com/kaspersmjohansen/Cloud-Deployment/main/Cloud-Deployment.ps1 -wallpaper "$OSDCloudFolder\Wallpaper\wallpaper.jpg" -Verbose



# Create boot ISO
New-OSDCloud.iso -workspacepath $OSDCloudFolder