function ConvertTo-EncryptedString {
  [CmdletBinding()]
  param (
    # Encryption Key
    [Parameter(Mandatory=$true)]
    [string]
    $EncryptionKey,
    # Clear text to encrypt
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $PlainText
  )

  begin {
  }

  process {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $aesManaged = New-AesManagedObject -EncryptionKey $EncryptionKey
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]]$fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    Return [System.Convert]::ToBase64String($fullData)
  }

  end {
  }
}