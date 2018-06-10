function Get-CohesityCluster {
  [CmdletBinding()]
  param (
    
  )
  
  begin {
  }
  
  process {
    Write-Warning "This really probably won't work!!"
    Invoke-CohesityAPI -RequestMethod "GET" -RequestTarget "cluster"
  }
  
  end {
  }
}