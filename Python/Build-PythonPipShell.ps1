## For this to work, you need to install python 3 from python.org 64bit Windows.
## You also need to have the Architecture tools repo located at C:\TFSGIT\Architecture
#Python Alias
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location $dir

Set-Location "$PScriptRoot"
Write-Host "Upddating process/shell environment PATH" -ForegroundColor Green
#Python Alias
$path = gci "C:\Program Files (x86)\" -recurse -filter 'python.exe' -ErrorAction SilentlyContinue | %{ $_.VersionInfo } | select -ExpandProperty  FileName
if(Test-Path $path[0] ){
    $newPath = Split-Path -Path $path[0]
    #Add python folder to PATH HERE
    ..\Windows\Set-FirstEnvironmentPath.ps1 -NewPaths "$newPath"
    ..\Windows\Set-FirstEnvironmentPath.ps1 -NewPaths "$newPath\Scripts"
}

Set-Location $dir
#Install pip
if (Get-Command "pip" -errorAction SilentlyContinue)
{
    "pip exists"
}
else{
    "Downloading pip"
    python "get-pip/get-pip.py"
    python -m pip install --upgrade pip
}

if ((Get-Command "pip" -errorAction SilentlyContinue) -and (Get-Command "py" -errorAction SilentlyContinue))
{
    Write-Host "Dependencies and python/pip shell complete" -ForegroundColor Green
}
else{
    Write-Host "Failed to build the python and pip shell" -ForegroundColor Red
    exit 1
}