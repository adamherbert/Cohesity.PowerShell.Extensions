function Get-CohesityCluster {
  [CmdletBinding()]
  param (
    # IncludeStatistics
    [Parameter(Mandatory=$false)]
    [switch]
    $IncludeStatistics
  )

  begin {
  }

  process {
    Invoke-CohesityAPI -RequestMethod "GET" -RequestTarget "cluster" -RequestArguments @{ "fetchStats" = $IncludeStatistics }
  }

  end {
  }
}