Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $jsonConfigFile,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Get-Website $_})]
        [string]
        $iisSiteName
    )
Import-Module WebAdministration;
$x = Get-Content $jsonConfigFile | Out-String | ConvertFrom-Json
$appPath = "IIS:\Sites\$iisSiteName\";

#used for checking json properties
function ValidateObjectProperty{
    param (
        $object,
        [string]$prop
    )
    return [bool]($object.PSobject.Properties.name -match $prop);
}

function HasAppSettings{
    param ($app)
    if((ValidateObjectProperty -object $app -prop "Name") -ne $true){
        return $false;
    }
    if((ValidateObjectProperty -object $app -prop "AppPoolName") -ne $true){
        return $false;
    }
    if((ValidateObjectProperty -object $app -prop "PhysicalPath") -ne $true){
        return $false;
    }
    return $true;
}
function HasAppPoolSettings{
    param($app)
    if((ValidateObjectProperty -object $app -prop "AppPoolName") -ne $true){
        return $false;
    }
    if((ValidateObjectProperty -object $app -prop "DotNetVersion") -ne $true){
        return $false;
    }
    if((ValidateObjectProperty -object $app -prop "Pipeline") -ne $true){
        return $false;
    }
    if((ValidateObjectProperty -object $app -prop "IdentityType") -ne $true){
        return $false;
    }
    return $true;
}
#function taken from example found on https://www.habaneroconsulting.com/stories/insights/2013/set-the-specific-times-to-recycle-an-application-pool-with-powershell
#get collection of recycle time - appPool.recycling.periodicRestart.schedule.collection
function Set-ApplicationPoolRecycleTimes {
 
    param (
        [string]$ApplicationPoolName,
        [string[]]$RestartTimes
    )
     
    Write-Output "Updating recycle times for $ApplicationPoolName";
     
    # Delete all existing recycle times
    Clear-ItemProperty IIS:\AppPools\$ApplicationPoolName -Name Recycling.periodicRestart.schedule;
     
    foreach ($restartTime in $RestartTimes) {
 
        Write-Output "Adding recycle at $restartTime";
        # Set the application pool to restart at the time we want
        New-ItemProperty -Path "IIS:\AppPools\$ApplicationPoolName" -Name Recycling.periodicRestart.schedule -Value @{value=$restartTime};
         
    } # End foreach restarttime
     
} # End function Set-ApplicationPoolRecycleTimes
function UpdateAppPool{
    param($app)

    #Application Pool
    $iisAppPoolName = $app.AppPoolName; 
    $iisIdentityType = $app.IdentityType;

    #if web app pool does not exist, force a new app pool
    if((Test-Path "IIS:\AppPools\$iisAppPoolName") -eq 0)
    {
        New-WebAppPool -Name $iisAppPoolName -Force;
    }

    #set app pool settings
    $appPool = Get-Item "IIS:\AppPools\$iisAppPoolName";
    $appPool.managedRuntimeVersion = $app.DotNetVersion;
    $appPool.managedPipeLineMode = $app.Pipeline;
    $appPool.processModel.identityType = $iisIdentityType;
    
    ####Optional settings - Username and password####
    #specific user is 3, localsystem is 0
    #https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/applicationpools/add/processmodel#configuration
    if($iisIdentityType -eq 3){   
        
        if((ValidateObjectProperty -object $app -prop "UserName") -eq $true){
            $appPool.processModel.username = $app.UserName; 
        }
        if((ValidateObjectProperty -object $app -prop "Password") -eq $true){
            $appPool.processModel.password = $app.Password;  
        }
    }

    ####Optional settings - IdleTimeout####
    if((ValidateObjectProperty -object $app -prop "IdleTimeout") -eq $true){
        $appPool.processModel.idleTimeout = $app.IdleTimeout;
    }
    $appPool | Set-Item;

    ####Optional settings - Recycle time####
    #recycle time @("4:00", "6:00", "17:00")
    if((ValidateObjectProperty -object $app -prop "RecycleTimes") -eq $true){
        Set-ApplicationPoolRecycleTimes -ApplicationPoolName $iisAppPoolName -RestartTimes $app.RecycleTimes
    }

}

function UpdateApplication{
    param($app)
    
    $appName = $app.Name; 
    $physicalPath = $app.PhysicalPath;
    $iisAppPoolName = $app.AppPoolName;

    #if there is no physical directory for that app, create directory
    if((Test-Path $physicalPath) -eq 0)
    {  
        Write-Output "Creating directory $physicalPath";
        New-Item -ItemType directory -Path $physicalPath; 
    }

    #if web application already exists, remove existing app
    if($null -ne (Get-WebApplication -Site $iisSiteName -Name $appName))
    {
        Write-Output "$appName already exists, removing $appName to $iisSiteName";
        Remove-WebApplication -Name $appName -Site $iisSiteName
    }
    #create new web app
    Write-Output "Creating application $appName";
    New-WebApplication -Name $appName -ApplicationPool $iisAppPoolName -Site $iisSiteName -PhysicalPath $physicalPath;
}

#MAIN START
#loop through applications
foreach($app in $x.Applications)
{
    $updateApp = HasAppSettings -app $app;
    $updateAppPool = HasAppPoolSettings -app $app;
    #App Pool
    if($updateAppPool){
        Write-Output "Settings found for app pool $app";
        Write-Output " ";
        UpdateAppPool -app $app;
    }
    #Application
    if($updateApp -eq $true){
        Write-Output "Settings found for application $app";
        Write-Output " ";
        UpdateApplication -app $app;
    } 
}

