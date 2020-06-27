# Start a transcript
#
$logging = $false
if (!(Test-Path "$Env:USERPROFILE\Documents\WindowsPowerShell\Transcripts"))
{
    if (!(Test-Path "$Env:USERPROFILE\Documents\WindowsPowerShell"))
    {
        $rc = New-Item -Path "$Env:USERPROFILE\Documents\WindowsPowerShell" -ItemType directory
    }
    $rc = New-Item -Path "$Env:USERPROFILE\Documents\WindowsPowerShell\Transcripts" -ItemType directory
}
$curdate = $(get-date -Format "yyyyMMddhhmmss")
if($logging){
    Start-Transcript -Path "$Env:USERPROFILE\Documents\WindowsPowerShell\Transcripts\PowerShell_transcript.$curdate.txt"
}
# Alias Git
#
New-Alias -Name git -Value "C:\Program Files\Git\bin\git.exe"

#Python Alias
if(Test-Path "C:\Program Files (x86)\Python*")
{
    $dir = $MyInvocation.MyCommand.Path | Split-Path
    &"$dir\Python\Build-PythonPipShell.ps1" --quiet --no-verbose | out-null
}
Set-Location c:\