function ConvertFrom-EncryptedString {
  [CmdletBinding()]
  param (
    # Encryption Key
    [Parameter(Mandatory = $true)]
    [string]
    $EncryptionKey,
    # Clear text to encrypt
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]
    $EncryptedText
  )

  begin {
  }

  process {
    $bytes = [System.Convert]::FromBase64String($EncryptedText)
    $InitializationVector = $bytes[0..15]
    $aesManaged = New-AesManagedObject -EncryptionKey $EncryptionKey -InitializationVector $InitializationVector
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    Return [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
  }

  end {
  }
}