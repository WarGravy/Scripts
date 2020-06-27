<#
Use this for configuring remote powershell over https using winrm on a windows server.
Here's how to use it:
    . \configureRemotePS.ps1 "servername.fqdn"
#>
Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Resolve-DnsName -Name $_})]
        [string]
        $computerFQDN
    )
$myThumb = Get-ChildItem Cert:\LocalMachine -Recurse | Where-Object {$_.subject -Match $computerFQDN -and $_.EnhancedKeyUsageList -match "Server Authentication"} | Sort-Object NotAfter | Select-Object -Last 1 | Select-Object -ExpandProperty Thumbprint
if (test-wsman -ComputerName $computerFQDN -UseSSL) {
    Remove-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address="*";Transport="HTTPS"}
}
New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address="*";Transport="HTTPS"} -ValueSet @{Hostname=$computerFQDN;CertificateThumbprint=$myThumb}