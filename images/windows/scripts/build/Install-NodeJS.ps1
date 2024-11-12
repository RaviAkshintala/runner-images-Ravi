################################################################################
##  File:  Install-NodeJS.ps1
##  Desc:  Install nodejs-lts and other common node tools.
##         Must run after python is configured
################################################################################

$prefixPath = 'C:\npm\prefix'
$cachePath = 'C:\npm\cache'

New-Item -Path $prefixPath -Force -ItemType Directory
New-Item -Path $cachePath -Force -ItemType Directory


$defaultVersion = (Get-ToolsetContent).node.default
# Install default Node.js using the new method
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tj/n/master/bin/n" -OutFile "$env:USERPROFILE\n"
& "$env:USERPROFILE\n" $defaultVersion

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
