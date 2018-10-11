#requires -Version 5.1

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
if ($PSVersionTable.PSVersion.Major -ge "6") {
  $PSDefaultParameterValues.Add("Invoke-RestMethod:SkipCertificateCheck",$true)
}
else {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
    Add-Type @"
      using System;
      using System.Net;
      using System.Net.Security;
      using System.Security.Cryptography.X509Certificates;
      public class ServerCertificateValidationCallback {
        public static void Ignore() {
          ServicePointManager.ServerCertificateValidationCallback +=
            delegate (
              Object obj,
              X509Certificate certificate,
              X509Chain chain,
              SslPolicyErrors errors
            ) { return true; };
        }
      }
"@
  }
  [ServerCertificateValidationCallback]::Ignore()
}

# Export Public functions
Export-ModuleMember -Function $Public.Basename