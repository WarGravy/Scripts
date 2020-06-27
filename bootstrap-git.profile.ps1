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
if(Test-Path "$Env:USERPROFILE\AppData\Local\Programs\Python\"){
    ./Python/Build-PythonPipShell.ps1
}
Set-Location c:\