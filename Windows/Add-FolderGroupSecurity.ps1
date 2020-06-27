<#
    $access: Modify, FullControl, Read, ReadAndExecute
    Microsoft Documentation
        PropagationFlags: https://docs.microsoft.com/en-us/previous-versions/ms229747(v=vs.110)
        FileSystemRights: https://docs.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemrights?redirectedfrom=MSDN&view=netframework-4.7.2 

#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]
    $folderPath,
    [Parameter(Mandatory=$true)] 
    $userGroup,
    [Parameter(Mandatory=$true)] 
    $access
)
$acl = Get-Acl $folderPath

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($userGroup,$access, "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)

Set-Acl $folderPath $acl