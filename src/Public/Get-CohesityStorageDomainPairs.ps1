function Get-CohesityStorageDomainPairs {
    [CmdletBinding()]
    param (
        # The FQDN or IP address of any node in the remote Cohesity Cluster
        [Parameter(Mandatory = $true)]
        [string]
        $RemoteServer,
        # User credentials for the remote cluster
        [Parameter(Mandatory = $true)]
        [pscredential]
        $RemoteClusterCredential
    )
    
    begin {
        $RemoteSession = New-PSSession
    }
    
    process {
        Invoke-Command -Session $RemoteSession -ScriptBlock { 
            Connect-CohesityCluster -Server $Using:RemoteServer -Credential $Using:RemoteClusterCredential -ErrorAction Stop | Out-Null
        }
        $StorageDomainPairs = New-Object System.Collections.Generic.List[System.Object]
        $RemoteStorageDomainList = Invoke-Command -Session $RemoteSession -ScriptBlock { Get-CohesityStorageDomain | Select-Object Id, Name }
        $LocalStorageDomainList = Get-CohesityStorageDomain | Select-Object Id, Name
        ForEach ($RemoteStorageDomain in $RemoteStorageDomainList) {
            ForEach ($LocalStorageDomain in $LocalStorageDomainList) {
                if ($LocalStorageDomain.Name -eq $RemoteStorageDomain.Name) {
                    $StorageDomainPairs.Add(@{
                        "LocalStorageDomainId"    = $LocalStorageDomain.Id;
                        "LocalStorageDomainName"  = $LocalStorageDomain.Name;
                        "RemoteStorageDomainId"   = $RemoteStorageDomain.Id;
                        "RemoteStorageDomainName" = $RemoteStorageDomain.Name;
                    })
                }    
            }
        }
        return $StorageDomainPairs.ToArray()
    }
    
    end {
        Remove-PSSession $RemoteSession
    }
}