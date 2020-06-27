Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $jsonConfigFileSource,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $jsonConfigFileTarget
    )
$source = Get-Content $jsonConfigFileSource | Out-String | ConvertFrom-Json
$target = Get-Content $jsonConfigFileTarget | Out-String | ConvertFrom-Json
#used for checking json properties
function ValidateObjectProperty{
    param (
        $object,
        [string]$prop
    )
    return [bool]($object.PSobject.Properties.name -match $prop);
}
function CompareApps{
    param(
        $source,
        $target
    )
    $result = @{
        "Name"= $source.Name;
        "PhysicalPath"= $source.PhysicalPath;
        "AppPoolName" = $source.AppPoolName;
        "IdentityType" = $source.IdentityType;
        "DotNetVersion" = $source.DotNetVersion;
        "Pipeline"= $source.Pipeline;
        "IdleTimeout" = $source.IdleTimeout;
        "RecycleTimes" = $source.RecycleTimes;
        "UserName"=$source.UserName;
    }
    if($source.IdentityType -ge 3){
        $result | Add-Member Password "Blank";
    }

    #Change log
    #$result = @{  
    #}
    if($source.PhysicalPath -ne $target.PhysicalPath){
        $result | Add-Member PreviousPhysicalPath $target.PhysicalPath;
    }
    if($source.AppPoolName -ne $target.AppPoolName){
        $result | Add-Member PreviousAppPoolName $target.AppPoolName;
    }
    if($source.DotNetVersion -ne $target.DotNetVersion){
        $result | Add-Member PreviousDotNetVersion $target.DotNetVersion;
    }
    if($source.Pipeline -ne $target.Pipeline){
        $result | Add-Member PreviousPipeline $target.Pipeline;
    }   
    if($source.IdentityType -ne $target.IdentityType){
        $result | Add-Member PreviousIdentityType $target.IdentityType;
    }
    if($source.UserName -ne $target.UserName){
        $result | Add-Member PreviousUserName $target.UserName;
    }
    if($source.RecycleTimes -ne $target.RecycleTimes){
        $result | Add-Member PreviousRecycleTimes $target.RecycleTimes;
    }
    if($source.IdleTimeout -ne $target.IdleTimeout){
        $result | Add-Member PreviousIdleTimeout $target.IdleTimeout;
    }

    #$result | Add-Member PreviousSettings $result;
    return $result;
}
function AppsAreEqual{
    param(
        $source,
        $target
    )

    if (($source.Name -eq $target.Name) -and 
    ($source.AppPoolName -eq $target.AppPoolName) -and 
    ($source.UserName -eq $target.UserName) -and 
    ($source.IdentityType -eq $target.IdentityType) -and 
    ($source.DotNetVersion -eq $target.DotNetVersion)-and 
    ($source.Pipeline -eq $target.Pipeline) -and 
    ($source.RecycleTimes -eq $target.RecycleTimes) -and 
    ($source.IdleTimeout -eq $target.IdleTimeout)){
        return $true;
    }
    return $false;
}

#MAIN START
$Applications = @();

#loop through applications
foreach($app in $source.Applications)
{
    $foundApp = $false;
    foreach($appT in $target.Applications)
    {
        if($app.Name -eq $appT.Name){
            $foundApp = $true;
            $noChangesMade = (AppsAreEqual -source $app -target $appT);
            if($noChangesMade -eq $false){
                $result = CompareApps -source $app -target $appT;
                $result | Add-Member ChangesMade $true;
                $result | Add-Member AppExists $foundApp;
                $Applications += $result;
            }    
        }
    }
    if($foundApp -eq $false){
        #add new
        $app | Add-Member AppExists $foundApp;
        $Applications += $app;
    }
}
$Result = @{};
    $Result["Applications"] = $Applications | sort-object { $_.Name };
    $Result | ConvertTo-Json -Depth 10 | Out-File -filepath C:\temp\diffIIS.json;

