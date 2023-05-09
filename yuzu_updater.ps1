# Set the base URL of the repository
$baseUrl = "https://api.github.com/repos/pineappleEA/pineapple-src"

# Get the latest release information
$latestRelease = Invoke-RestMethod -Uri "$baseUrl/releases/latest"

# Find the Windows release asset
$windowsAsset = $latestRelease.assets | Where-Object { $_.name -like "*.zip" }

# Set the URL of the release
$url = $windowsAsset.browser_download_url

# Set the path to the settings file
$currentDirectory = (Get-Location).Path
$settingsFile = "$currentDirectory\pineapple-src-settings.json"

# Check if the settings file exists
if (Test-Path $settingsFile) {
    # Load the settings from the file
    $settings = Get-Content $settingsFile | ConvertFrom-Json
    $destinationFolder = $settings.destinationFolder
} else {
    # Prompt the user to select the destination folder
	Write-Host "Where to download"
    $destinationFolder = (New-Object -ComObject Shell.Application).BrowseForFolder(0, "Select a destination folder:", 0, 0).Self.Path

    # Save the destination folder to the settings file
    $settings = @{
        destinationFolder = $destinationFolder
    }
    $settings | ConvertTo-Json | Out-File $settingsFile
}

# Set the destination path
$destination = "$destinationFolder\$($windowsAsset.name)"


Invoke-WebRequest -Uri $url -OutFile $destination
# Extract the zip file and overwrite existing files
Expand-Archive -Path $destination -DestinationPath $destinationFolder -Force

# Delete the downloaded zip file
Remove-Item $destination

# Set the path to the .xz file
$xzFile = "$destinationFolder\*.xz"

# Delete the .xz file
Remove-Item $xzFile

# Set the path to yuzu.exe
$yuzuPath = "$destinationFolder\yuzu-windows-msvc-early-access\yuzu.exe"

# Notify the user that the update is complete
Write-Host "Done, run yuzu."

# Execute yuzu.exe (algunos antivirus lo detectan como virus
#& $yuzuPath

