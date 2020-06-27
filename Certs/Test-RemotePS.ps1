<#
Script used to validate that configureRemotePS.ps1 worked correctly.

How to use?
Run this script from your machine as an account that has admin access to a server:
    . \testRemotePS.ps1 "servername" "AccountName"
#>
Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Resolve-DnsName -Name $_})]
        [string]
        $computerFQDN,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $cred
    )
    invoke-command -computername $computerFQDN -scriptblock { Get-Host } -UseSSL -Credential $cred