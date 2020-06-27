param(
    $SharePhysicalPath = "C:\temp\TestShare",
    $ShareName = "TestShare",
    [Parameter(Mandatory=$true)]
    [ValidateScript({Get-Website $_})]
    [string]
    $iisSiteName,
    [switch] $modifyIIS,
    [switch] $modifyShare
)
#MAIN
<#  
    Configures IIS Site web apps to map to D drive instead of C drive, and configures a new SMBShare
 #>
#Export web apps from IIS site
.\exportIISWebAppsToJson.ps1 $iisSiteName

#Replace Physical Location with D drive location
$iisSiteJson = "C:\temp\$iisSiteName.json"
((Get-Content -path $iisSiteJson -Raw) -replace 'C:','D:') | Set-Content -Path $iisSiteJson

Write-Host "Configuring the share $ShareName (mapped to physical location $SharePhysicalPath)";
if($modifyShare){
    #Create Share
    ..\..\Windows\New-Share.ps1 -SharePhysicalPath $SharePhysicalPath -ShareName $ShareName

    #Set Security
    ..\..\Windows\Add-FolderGroupSecurity.ps1 -folderPath $SharePhysicalPath -userGroup "IUSR" -access "Modify"
}

Write-Host "Configuring the IIS site $iisSiteName from the file $iisSiteJson";
if($modifyIIS){
    .\configureIISSiteFromJSON.ps1 -jsonConfigFile $iisSiteJson -iisSiteName $iisSiteName
}