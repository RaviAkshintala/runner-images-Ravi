################################################################################
##  File:  Install-NodeJS.ps1
##  Desc:  Install nodejs-lts and other common node tools.
##         Must run after python is configured
################################################################################

$prefixPath = 'C:\npm\prefix'
$cachePath = 'C:\npm\cache'

New-Item -Path $prefixPath -Force -ItemType Directory
New-Item -Path $cachePath -Force -ItemType Directory

# Install 'n' package manager if not installed
$nodeInstallDir = 'C:\Program Files\nodejs'
if (-not (Test-Path "$nodeInstallDir\n")) {
    Write-Host "Installing 'n' package manager..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tj/n/master/bin/n" -OutFile "$env:USERPROFILE\n"
    bash "$env:USERPROFILE\n" -c "npm install -g n"
}

# Install the default Node.js version using 'n'
$defaultVersion = (Get-ToolsetContent).node.default
Write-Host "Installing Node.js version $defaultVersion using 'n'..."
bash "$env:USERPROFILE\n" -c "n $defaultVersion"

[Environment]::SetEnvironmentVariable("npm_config_prefix", $prefixPath, "Machine")
$env:npm_config_prefix = $prefixPath

npm config set cache $cachePath --global
npm config set registry https://registry.npmjs.org/

$globalNpmPackages = (Get-ToolsetContent).npm.global_packages
$globalNpmPackages | ForEach-Object {
    npm install -g $_.name
}

Invoke-PesterTests -TestFile "Node"
