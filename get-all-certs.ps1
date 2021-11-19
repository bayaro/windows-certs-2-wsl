#

$StoreToDir = "all-certificates"
$InsertLineBreaks=1

If (Test-Path $StoreToDir) {
    $path = "{0}\*" -f $StoreToDir
    Remove-Item $StoreToDir -Recurse -Force
}
New-Item $StoreToDir -ItemType directory

Get-ChildItem -Recurse cert: `
  | Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] } `
  | ForEach-Object {
    $name = $_.Subject -replace '[\W]', '_'
    $oPem=new-object System.Text.StringBuilder
    [void]$oPem.AppendLine("-----BEGIN CERTIFICATE-----")
    [void]$oPem.AppendLine([System.Convert]::ToBase64String($_.RawData,$InsertLineBreaks))
    [void]$oPem.AppendLine("-----END CERTIFICATE-----")

    $path = "{0}\{1}.pem" -f $StoreToDir,$name

    # the exported list of certificates contains certificates with similar subject
    # let's put them in separate indexed files
    $idx = 0
    While (Test-Path $path) {
      $idx++
      $path = "{0}\{1}--{2}.pem" -f $StoreToDir,$name,$idx
    }
    If ($idx -gt 0) {
      $path
    }

    # TODO unfortunately same certificates duplicates each other
    # it's better to add a check for duplicates just here

    $oPem.toString() | add-content $path
    #Exit(0)
  }

# The End
