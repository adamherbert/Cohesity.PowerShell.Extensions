function New-AesManagedObject {
  [CmdletBinding()]
  param (
    # Encryption Key
    [Parameter(ParameterSetName="NewObject", Mandatory=$true)]
    [string]
    $EncryptionKey,
    # InitilizationVector
    [Parameter(ParameterSetName="NewObject", Mandatory=$false)]
    [byte[]]
    $InitializationVector,
    # Generate New Key
    [Parameter(ParameterSetName="NewKey", Mandatory=$true)]
    [switch]
    $NewKey
  )

  begin {
  }

  process {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($NewKey) {
      $aesManaged.GenerateKey()
      Return [System.Convert]::ToBase64String($aesManaged.Key)
    }
    else {
      if ($InitializationVector) {
        $aesManaged.IV = $InitializationVector
      }
      $aesManaged.Key = [System.Convert]::FromBase64String($EncryptionKey)
      Return $aesManaged
    }
  }

  end {
  }
}