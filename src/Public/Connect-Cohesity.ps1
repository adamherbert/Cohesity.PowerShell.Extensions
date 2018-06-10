function Connect-Cohesity {
  [CmdletBinding()]
  param (
    # Cohesity Virtual IP (VIP)
    [Parameter(Mandatory=$true)]
    [string]
    $CohesityVIP,
    # Credentials
    [Parameter(Mandatory=$false)]
    [pscredential]
    $Credential
  )
  
  begin {
    if (-not $Credential) {
      $Credential = Get-Credential `
        -Message "Please provide username and password for Cohesity VIP ($CohesityVIP)" `
        -Title "Cohesity Login to $CohesityVIP" 
    }
  }
  
  process {
    $networkCredential = $Credential.GetNetworkCredential()

    $RequestArguemnts = @{
      'domain' = $networkCredential.Domain
      'username' = $networkCredential.UserName
      'password' = $networkCredential.Password
    }

    Invoke-CohesityAPI `
      -RequestTarget 'accessTokens' `
      -RequestMethod 'POST' `
      -RequestArguments $RequestArguemnts
      -ErrorAction 'Stop'
  }
  
  end {
    Remove-Variable $networkCredential
    Remove-Variable $RequestArguemnts
  }
}