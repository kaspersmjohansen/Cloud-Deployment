$OSDCloudFolder = "C:\Working\OSDCloud"
$OSDWallpaperFolder = $OSDCloudFolder + "\" + "wallpaper"

# Clear sreen
cls

# Configure security protocol for new connections
Write-Host "Configuring TLS1.2 security protocol for new connections" -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = "tls12"

    # Download latest NuGet Package Provider
    Write-Host "Downloading and installing latest NuGet Package Provider" -ForegroundColor Cyan
    If (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget"))
    {
        Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
    }

If (!(Test-Path -Path $OSDCloudFolder))
{
New-Item -Path $OSDCloudFolder -ItemType Directory -Verbose
}

Import-Module PowerShellGet -Force
Install-Module -Name OSD -force
New-OSDCloud.template -WinRE -SetAllIntl da-dk -SetInputLocale da-dk -verbose

# Autopilot creds
$Autopilotcreds = Get-Credential
Install-Module -Name AzureAD -Force
Install-Module -Name WindowsAutopilotIntune -Force
Install-module Microsoft.Graph -Force
Import-Module Microsoft.Graph
Connect-MSGraph -Credential $Autopilotcreds
$Autopilotdisplayname = (Get-AutopilotProfile).displayname

New-OSDCloud.workspace -WorkspacePath $OSDCloudFolder

# Autopilot configuration
If (!(Test-Path -Path "$OSDCloudFolder\Autopilot"))
{
New-Item -Path $OSDCloudFolder -Name Autopilot -ItemType Directory
New-Item -Path "$OSDCloudFolder\Autopilot" -Name Profiles -ItemType Directory
}
Get-AutopilotProfile | Where-Object DisplayName -eq $Autopilotdisplayname | ConvertTo-AutopilotConfigurationJSON | Out-File -FilePath "$OSDCloudFolder\Autopilot\Profiles\AutoPilotConfigurationFile.json" -Encoding ASCII

# New-OSDCloud.workspace -WorkspacePath $OSDCloudFolder
#Edit-OSDCloud.winpe -WorkspacePath $OSDCloudFolder

# Create wallpaper folder and download wallpaper
If (!(Test-Path -Path "$OSDWallpaperFolder"))
{
New-Item -Path "$OSDWallpaperFolder" -ItemType Directory -Verbose
}
Invoke-WebRequest -Uri https://github.com/kaspersmjohansen/Cloud-Deployment/raw/main/wallpaper.jpg -OutFile "$OSDWallpaperFolder\wallpaper.jpg"

# New-OSDCloud.workspace -workspacepath $OSDCloudFolder -Verbose
Edit-OSDCloud.winpe -workspacepath $OSDCloudFolder -WebPSScript https://raw.githubusercontent.com/kaspersmjohansen/Cloud-Deployment/main/Cloud-Deployment.ps1 -wallpaper "$OSDCloudFolder\Wallpaper\wallpaper.jpg" -CloudDriver WiFi -DriverPath "C:\Users\kjo\OneDrive - edgemo\OSDCloud Drivers\WiFi" -Verbose

# Create boot ISO
New-OSDCloud.iso -workspacepath $OSDCloudFolder