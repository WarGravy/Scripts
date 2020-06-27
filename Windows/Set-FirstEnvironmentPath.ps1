param(
    [string[]] $NewPaths = @("C:\ORACLE\product\12.1.0\client_32\bin"),
    [string] $EnvironmentVariableTarget = "Process")

Set-StrictMode -Version Latest
#GET PATH
[string] $path = [Environment]::GetEnvironmentVariable("Path", $EnvironmentVariableTarget)
If ($path -ne $null)
{
    Write-Output $path
    Write-Output "Cleaning path..."
    #REMOVE PATHS IF THEY EXIST
    foreach($np in $NewPaths){
        $path = $path.Replace($np, "")
        $path = $path.Replace(";;", ";")
    }
    
    #ADD PATHS IN ORDER ON TOP
    Write-Output "Setting new path..."
    foreach($np in $NewPaths){
        $path = $np + ";" + $path
        $path = $path.Replace(";;", ";")
    }

    #SET PATH
    [Environment]::SetEnvironmentVariable("Path", $path, $EnvironmentVariableTarget)
}
#GET PATH
.\Get-EnvironmentPath.ps1 -EnvironmentVariableTarget $EnvironmentVariableTarget
