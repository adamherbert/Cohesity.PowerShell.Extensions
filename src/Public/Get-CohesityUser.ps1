function Get-CohesityUser {
  [CmdletBinding()]
  param (
    # Optionally specify a list of usernames to filter by
    [Parameter(Mandatory = $false)]
    [string[]]
    $Name,
    # Optionally specify a list of email addresses to filter by
    [Parameter(Mandatory = $false)]
    [string[]]
    $EmailAddress,
    # Optionally specify a domain to filter by. If no domain is specified, all
    # users on the Cohesity Cluster are searched. If a domain is specified,
    # only users on the Cohesity Cluster associated with that domain are
    # searched.
    [Parameter(Mandatory = $false)]
    [string]
    $Domain
  )

  begin {
    $RequestArguments = @{}
    if ($Name) {
      $RequestArguments['usernames'] = $Name -join ","
    }
    if ($EmailAddress) {
      $RequestArguments['emailAddresses'] = $EmailAddress -join ","
    }
    if ($Domain) {
      $RequestArguments['domain'] = $Domain
    }

  }

  process {
    Invoke-CohesityAPI -RequestMethod "GET" -RequestTarget "users" -RequestArguments $RequestArguments
  }

  end {
  }
}