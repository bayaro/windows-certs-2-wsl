function Set-CaCerts {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter()]
        [string]
        $CertOutPath = "$env:USERPROFILE\all-certificates\cacerts.pem",
        [Parameter()]
        [switch]
        $FailFast
    )
    #Requires -Version 6.0
    begin {
        if ($FailFast) {
            trap { Write-Error -Exception $_; return }  # Stop on error
        }
        # Collect the certs from the local machine
        $certs = Get-ChildItem -Path Cert:\ -Recurse | Where-Object -FilterScript { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and $_.Thumbprint }
        $certItem = New-Item -Path ($CertOutPath | Split-Path -Parent) -Name ($CertOutPath | Split-Path -Leaf) -ItemType File -Confirm:$ConfirmPreference -Force  # Create if not exists
        if ($null -eq $certItem -and $WhatIfPreference) {
            $certItem = [System.IO.FileInfo]::new($CertOutPath)  # For WhatIf, indicates hypothetical output file (not created)
        }
    }
    process {
        for ($i = 0; $i -lt $certs.Count; $i++) {
            Write-Progress -Activity 'Aggregating certificates' -PercentComplete (100 * $i / $certs.Count)
            @'
-----BEGIN CERTIFICATE-----
{0}
-----END CERTIFICATE-----
'@ -f ([System.Convert]::ToBase64String($certs[$i].RawData) -replace '(.{64})', "`$1`n") | Add-Content -Path $certItem -Force
        }
    }
}
if ($MyInvocation.InvocationName -eq '.') {
    Set-CaCerts
}
=======
#

$StoreToDir = "all-certificates"
$CertExtension = "pem" # use "crt" for usage on windows systems
$InsertLineBreaks=1

If (Test-Path $StoreToDir) {
    $path = "{0}\*" -f $StoreToDir
    Remove-Item $StoreToDir -Recurse -Force
}
New-Item $StoreToDir -ItemType directory

# If you want to filter by Cert Usage (ex. for language independent match proividing server authentificaten Certs: "(1.3.6.1.5.5.7.3.1)"), just add:
# -and -not $_.Archived -and ( $_.EnhancedKeyUsageList -match '(1.3.6.1.5.5.7.3.1)' -or -not $_.EnhancedKeyUsageList )
Get-ChildItem -Recurse cert: `
  | Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and $_.NotAfter.Date -gt (Get-Date).Date } `
  | ForEach-Object {

    # Write Cert Info (ex. for CSV holding Meta Data); Log Info having full names and additional values for reference
    Write-Output "$($_.Thumbprint);$($_.GetSerialNumberString());$($_.Archived);$($_.GetExpirationDateString());$($_.EnhancedKeyUsageList);$($_.GetName())"

    # append "Thumbprint" of Cert for unique file names
    $name = "$($_.Thumbprint)--$($_.Subject)" -replace '[\W]', '_'
    $max = $name.Length

    # reduce length to prevent filesystem errors
    if ($max -gt 150) { $max = 150 }
    $name = $name.Substring(0, $max)

    # build path
    $path = "{0}\{1}.{2}" -f $StoreToDir,$name,$CertExtension
    if (Test-Path $path) { continue } # next if cert was already written

    $oPem=new-object System.Text.StringBuilder
    [void]$oPem.AppendLine("-----BEGIN CERTIFICATE-----")
    [void]$oPem.AppendLine([System.Convert]::ToBase64String($_.RawData,$InsertLineBreaks))
    [void]$oPem.AppendLine("-----END CERTIFICATE-----")

    $oPem.toString() | add-content $path
  }

# The End