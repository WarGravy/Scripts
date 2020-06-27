<#
    1. Removes any existing shares that have the share name
    2. Creates a folder if folder needs to be created
    3. Creates a share where "everyone" has Change and Read rights
#>
param(
    $SharePhysicalPath,
    $ShareName
)
#MAIN
If (GET-SMBShare -Name $ShareName -ea 0)
{
    Remove-SmbShare -Name $ShareName;
}
If(!(Test-Path $SharePhysicalPath)){
    New-Item $SharePhysicalPath -Type directory;
}
New-SmbShare -Name $ShareName -Path $SharePhysicalPath -ChangeAccess 'Everyone'