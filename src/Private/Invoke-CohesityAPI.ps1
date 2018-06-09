function Invoke-CohesityAPI {
  [CmdletBinding()]
  param (
    # Method
    [Parameter(Mandatory=$true)]
    [ValidateSet('get', 'post', 'put', 'delete')]
    [String]
    $Method,
    # URI
    [Parameter(Mandatory=$true)]
    [String]
    $URI
  )
  
  begin {
    if ($Method -ieq 'post' -and $URI -match 'accessTokens') {
      continue
    }
    elseif (-not $script:CohesityToken) {
      Write-Error 'Please authenticate before making any Cohesity API calls!'
    }
  }
  
  process {

  }
  
  end {
  }
}