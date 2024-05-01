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
# The End
