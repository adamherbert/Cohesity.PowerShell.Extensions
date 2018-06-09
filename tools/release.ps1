﻿<#
.SYNOPSIS
	Generates a manifest for the module
	and bundles all of the module source files
	and manifest into a distributable ZIP file.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [version]$ModuleVersion
)

$ErrorActionPreference = "Stop"

Write-Host "Building release for v$moduleVersion"

$scriptPath = Split-Path -LiteralPath $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })

$projectName = (Split-Path $scriptPath | Split-Path -Leaf)
$projectPath = (Join-Path (Split-Path $scriptPath) '')
$src = (Join-Path (Split-Path $scriptPath) 'src')
$dist = (Join-Path (Split-Path $scriptPath) 'dist')
if (Test-Path $dist) {
    Remove-Item $dist -Force -Recurse
}
New-Item $dist -ItemType Directory | Out-Null

Write-Host "Creating module manifest..."

$manifestFileName = Join-Path $dist "$projectName.psd1"

New-ModuleManifest `
    -Path $manifestFileName `
    -ModuleVersion $ModuleVersion `
    -Guid fe524c79-95a6-4d02-8e15-30dddeb8c874 `
    -Author 'Adam Herbert' `
    -CompanyName 'Cohesity' `
    -Copyright "(c) $((Get-Date).Year) Cohesity. All rights reserved." `
    -Description "$projectName" `
    -PowerShellVersion '3.0' `
    -DotNetFrameworkVersion '4.5' `
    -RootModule "$projectName.psm1"
    
Write-Host "Creating release archive..."

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