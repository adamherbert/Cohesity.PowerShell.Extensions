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
    if ([string]::IsNullOrEmpty($Session) -or $Session.ApiClient.IsAuthenticated -eq $false) {
      Write-Error "Failed to authenticate. Please connect to the Cohesity Cluster using 'Connect-CohesityCluster'"
    }

    $RequestHeaders['Authorization'] = "$($Session.ApiClient.AccessToken.TokenType) $($Session.ApiClient.AccessToken.AccessToken)"
  }

  process {
    # Create full URI based on RequestTarget
    $uri = "https://$($script:CohesityVIP)"
    # If requestTarget starts with a "/" then use it verbatim otherwise prefix with public
    if ($RequestTarget[0] -ne "/") {
      $RequestTarget = "public/$RequestTarget"
    }
    else {
      $RequestTarget = $RequestTarget[1..-1]
    }
    # Assemble the complete URI for the short resource name

    [string]$uri = (New-Object -TypeName 'System.Uri' -ArgumentList $Session.ApiClient.HttpClient.BaseAddress, $RequestTarget).ToString()
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