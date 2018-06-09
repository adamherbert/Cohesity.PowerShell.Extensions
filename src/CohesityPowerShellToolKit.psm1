#requires -Version 3.0

# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($import in @($Public + $Private)) {
  try {
    . $import.fullname
  }
  catch {
    Write-Error -Message "Failed to import function $($import.fullname): $_"
  }
}

# Disable SSL checking for communication to the array
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Export Public functions
Export-ModuleMember -Function $Public.Basename