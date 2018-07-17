function Get-CohesityCluster {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
    Invoke-CohesityAPI -RequestMethod "GET" -RequestTarget "cluster"
  }

  end {
  }
}