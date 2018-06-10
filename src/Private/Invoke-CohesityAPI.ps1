function Invoke-CohesityAPI {
  [CmdletBinding()]
  param (
    # Method
    [Parameter(Mandatory = $true)]
    [ValidateSet('get', 'post', 'put', 'delete')]
    [String]
    $RequestMethod,
    # URI
    [Parameter(Mandatory = $true)]
    [String]
    $RequestTarget,
    # Data Payload
    [Parameter(Mandatory = $false)]
    [hashtable]
    $RequestArguments,
    # Request Headers
    [Parameter(Mandatory = $false)]
    [hashtable]$RequestHeaders = @{}
  )
  
  begin {
    # Set minimum required headers
    $RequestHeaders['accept'] = 'application/json'
    $RequestHeaders['content-type'] = 'application/json'

    # Validate that we have a target VIP
    if ([string]::IsNullOrEmpty($script:CohesityVIP)) {
      Write-Error 'Please provide Cohesity VIP before API calls!'
    }
        
    # Validate that we are logged in or that a login call is being made
    if ($Method -ieq 'post' -and $URI -match 'accessTokens') {
      continue
    }
    elseif ([string]::IsNullOrEmpty($script:CohesityToken)) {
      Write-Error 'Please authenticate before making any Cohesity API calls!'
    }
  }
  
  process {
    # Create full URI based on RequestTarget
    $uri = "https://$($script:CohesityVIP)/irisservices/api/v1"
    if ($RequestTarget -notmatch "/") {
      $RequestTarget = "/public/$RequestTarget"
    }
    [string]$uri = (New-Object -TypeName 'System.Uri' -ArgumentList ([System.Uri]$uri),$RequestTarget).AbsoluteUri

    # If RequestMethod is GET then put parameters on URI
    if ( $Method -ieq 'get' ) {
      if ($RequestArguments.Count -gt 0) {
        $uri += '?'
        $uri += [string]::join("&", @(
            foreach ($pair in $RequestArguments.GetEnumerator()) { 
              if ($pair.Name) { 
                $pair.Name + '=' + $pair.Value 
              } 
            }))
      }
      try {
        $result = Invoke-RestMethod `
          -SkipCertificateCheck:$true `
          -ContentType 'application/json' `
          -Headers $RequestHeaders `
          -Uri $uri
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }
    # All other request methods will send a JSON payload
    else {
      try {
        $result = Invoke-RestMethod `
          -SkipCertificateCheck:$true `
          -ContentType 'application/json' `
          -Headers $RequestHeaders `
          -Uri $uri `
          -Body ($RequestArguments | ConvertTo-Json -Depth 100)
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }

    Write-Output $result | Format-List
  }
  
  end {
  }
}