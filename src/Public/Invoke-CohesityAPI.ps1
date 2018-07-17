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

    # Validate that we have a target VIP
    if ([string]::IsNullOrEmpty($script:CohesityVIP)) {
      Write-Error 'Please provide Cohesity VIP before API calls!'
    }

    # Validate that we are logged in or that a login call is being made
    if ($RequestMethod -ieq 'post' -and $RequestTarget -match 'accessTokens') {
      # Remove saved token information if logging in again
      Remove-Variable -Scope "script" -Name "CohesityTokenType" -ErrorAction SilentlyContinue
      Remove-Variable -Scope "script" -Name "CohesityToken" -ErrorAction SilentlyContinue
    }
    elseif ([string]::IsNullOrEmpty($script:CohesityToken)) {
      Write-Error 'Please authenticate before making any Cohesity API calls!'
    }
    else {
      $RequestHeaders['Authorization'] = "$($script:CohesityTokenType) $($script:CohesityToken)"
    }
  }

  process {
    # Create full URI based on RequestTarget
    $uri = "https://$($script:CohesityVIP)"
    # If requestTarget starts with a "/" then use it verbatim otherwise prefix with public
    if ($RequestTarget[0] -ne "/") {
      $RequestTarget = "/public/$RequestTarget"
    }
    # Assemble the complete URI for the short resource name
    [string]$uri = (New-Object -TypeName 'System.Uri' -ArgumentList ([System.Uri]$uri),("/irisservices/api/v1" + $RequestTarget)).AbsoluteUri

    # If RequestMethod is GET then put parameters on URI
    if ( $RequestMethod -ieq 'get' ) {
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
          -Method 'GET' `
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
      $body = $RequestArguments | ConvertTo-Json -Depth 100
      try {
        $result = Invoke-RestMethod `
          -Method $RequestMethod `
          -Headers $RequestHeaders `
          -SkipCertificateCheck:$true `
          -ContentType 'application/json' `
          -Uri $uri `
          -Body $body
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }

    Return $result
  }

  end {
  }
}