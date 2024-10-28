################################################################################
##  File:  Install-NodeJS.ps1
##  Desc:  Install nodejs-lts and other common node tools.
##         Must run after python is configured
################################################################################

$prefixPath = 'C:\npm\prefix'
$cachePath = 'C:\npm\cache'

New-Item -Path $prefixPath -Force -ItemType Directory
New-Item -Path $cachePath -Force -ItemType Directory

# Define the default version to install
$defaultVersion = (Get-ToolsetContent).node.default

# Define the GitHub repository and the path to the Node.js versions manifest
$repo = "actions/node-versions"
$manifestPath = "versions-manifest.json"

# Function to fetch the Node.js version from the manifest
function Get-NodeVersionFromManifest($version) {
    $manifestUrl = "https://raw.githubusercontent.com/$repo/main/$manifestPath"
    $manifest = Invoke-RestMethod -Uri $manifestUrl
    $nodeVersion = $manifest.versions | Where-Object { $_.version -eq $version } | Select-Object -First 1
    return $nodeVersion
}

# Resolve the version to install
$nodeVersionInfo = Get-NodeVersionFromManifest -version $defaultVersion
$versionToInstall = $nodeVersionInfo.version

# Download and extract the Node.js package
$nodeDownloadUrl = $nodeVersionInfo.files.windows.url
$nodeInstallerPath = "$env:TEMP\nodejs-$versionToInstall.zip"
Invoke-WebRequest -Uri $nodeDownloadUrl -OutFile $nodeInstallerPath
Expand-Archive -Path $nodeInstallerPath -DestinationPath "C:\Program Files\nodejs"

# Optionally, add Node.js to the system PATH
$env:Path += ";C:\Program Files\nodejs"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)

Add-MachinePathItem $prefixPath
Update-Environment

[Environment]::SetEnvironmentVariable("npm_config_prefix", $prefixPath, "Machine")
$env:npm_config_prefix = $prefixPath

npm config set cache $cachePath --global
npm config set registry https://registry.npmjs.org/

$globalNpmPackages = (Get-ToolsetContent).npm.global_packages
$globalNpmPackages | ForEach-Object {
    npm install -g $_.name
}

Invoke-PesterTests -TestFile "Node"
