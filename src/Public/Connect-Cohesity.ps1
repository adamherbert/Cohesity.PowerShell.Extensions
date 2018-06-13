function Connect-Cohesity {
  [CmdletBinding()]
  param (
    # Cohesity Virtual IP (VIP)
    [Parameter(Mandatory = $true)]
    [string]
    $CohesityVIP,
    # Credentials
    [Parameter(Mandatory = $false)]
    [pscredential]
    $Credential
  )
  
  begin {
    if (-not $Credential) {
      $Credential = Get-Credential `
        -Message "Please provide username and password for Cohesity VIP ($CohesityVIP)" `
        -Title "Cohesity Login to $CohesityVIP" 
    }
    $script:CohesityVIP = $CohesityVIP
  }
  
  process {
    $networkCredential = $Credential.GetNetworkCredential()

    $RequestArguemnts = @{
      'domain'   = $networkCredential.Domain
      'username' = $networkCredential.UserName
      'password' = $networkCredential.Password
    }

    try {
      $result = Invoke-CohesityAPI `
        -RequestTarget 'accessTokens' `
        -RequestMethod 'POST' `
        -RequestArguments $RequestArguemnts `
        -ErrorAction 'Stop'
    }
    catch {
      Write-Error $_.Exception.Message
    }

    $script:CohesityTokenType = $result.tokenType
    $script:CohesityToken = $result.accessToken

    Invoke-CohesityAPI -RequestMethod "GET" -RequestTarget "basicClusterInfo"
  }
  
  end {
      Remove-Variable $networkCredential -ErrorAction SilentlyContinue
      Remove-Variable $RequestArguemnts -ErrorAction SilentlyContinue
  }
}