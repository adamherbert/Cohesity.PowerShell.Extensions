<#
.SYNOPSIS
	Generates a manifest for the module
	and bundles all of the module source files
	and manifest into a distributable ZIP file.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [version]$ModuleVersion
)

$ErrorActionPreference = "Stop"

try {
  Import-Module -Name "powershell-yaml"
}
catch {
  Write-Verbose "Trying to install powershell-yaml"
  try {
    Install-Module -Name "powershell-yaml" -Scope AllUsers
  }
  catch {
    Write-Verbose "Couldn't install in AllUser scope "
    Install-Module -Name "powershell-yaml" -Scope CurrentUser
  }
  Import-Module -Name "powershell-yaml"
}

$scriptPath = Split-Path -LiteralPath $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })

$projectPath = (Join-Path (Split-Path $scriptPath) '')
$src = (Join-Path (Split-Path $scriptPath) 'src')
$dist = (Join-Path (Split-Path $scriptPath) 'dist')
if (Test-Path $dist) {
    Remove-Item $dist -Force -Recurse
}
New-Item $dist -ItemType Directory | Out-Null

$variables = Get-Content -Raw "$scriptPath/variables.yaml" | ConvertFrom-Yaml -AllDocuments

$projectName = $variables.projectName

if (-not $ModuleVersion) {
  $ModuleVersion = $variables.version
  if (-not $ModuleVersion) {
    $ModuleVersion = "0.1"
  }
}
else {
  $variables.version = $ModuleVersion
}

if (-not $variables.guid) {
  $guid = [guid]::NewGuid()
  $variables.guid = $guid
}

Write-Host "Building release for v$ModuleVersion"

Write-Host "Creating module manifest..."

$manifestFileName = Join-Path $dist "$projectName.psd1"

$manifestCmd = @"
New-ModuleManifest ``
    -Path "$manifestFileName" ``
    -ModuleVersion "$ModuleVersion" ``
    -Guid "$($variables.guid)" ``
    -Author "$($variables.author)" ``
    -CompanyName "$($variables.companyName)" ``
    -Copyright "(c) $((Get-Date).Year) $($variables.companyName). All rights reserved." ``
    -Description "$projectName" ``
    -RootModule "$projectName.psm1" ``
    -DotNetFrameworkVersion 4.5 ``
    -PowerShellVersion 3.0
"@

foreach ($option in $variables.manifestOptions.Keys) {
  $manifestCmd += " -$option `"$($variables.manifestOptions.$option)`""
}

& ([scriptblock]::create($manifestCmd))

Write-Host "Creating release archive..."

$variables | ConvertTo-Yaml | Out-File "$scriptPath/variables.yaml"

# Copy the distributable files to the dist folder.
Copy-Item -Path "$src\*" `
          -Destination $dist `
          -Recurse

Copy-Item -Path "$projectPath\LICENSE", "$projectPath\README.md" `
          -Destination $dist

# Requires .NET 4.5
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

$zipFileName = Join-Path ([System.IO.Path]::GetDirectoryName($projectPath)) "$([System.IO.Path]::GetFileNameWithoutExtension($manifestFileName))-$ModuleVersion.zip"

# Overwrite the ZIP if it already already exists.
if (Test-Path $zipFileName) {
    Remove-Item $zipFileName -Force
}

$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
$includeBaseDirectory = $false
[System.IO.Compression.ZipFile]::CreateFromDirectory($dist, $zipFileName, $compressionLevel, $includeBaseDirectory)

Remove-Item $dist -Force -Recurse
New-Item $dist -ItemType Directory | Out-Null
Move-Item $zipFileName $dist -Force