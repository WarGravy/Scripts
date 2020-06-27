Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Get-Website $_})]
        [string]
        $iisSiteName
    )
    Import-Module WebAdministration;
    $x = Get-Item "IIS:\AppPools\";
    $x = $x.Children;
    $identityType = @{};
    $identityType["LocalSystem"] = 0;
    $identityType["LocalService"] = 1;
    $identityType["NetworkService"] = 2;
    $identityType["SpecificUser"] = 3;
    $identityType["ApplicationPoolIdentity"] = 4;

    $appPools = @{};
    foreach($pool in $x.GetEnumerator())
    {
        $key = $pool.key;
        $p = Get-Item "IIS:\AppPools\$key";
        $appPools[$key] = @{
            "AppPoolName" = $key;
            "UserName" = $p.processModel.userName;
            "Password" = "blank";
            "IdentityType" = $p.processModel.identityType;
            "DotNetVersion" = $p.managedRuntimeVersion;
            "Pipeline"= $p.managedPipelineMode; 
            "RecycleTimes" = $p.recycling.periodicRestart.schedule.Collection;
            "IdleTimeout" = $p.processModel.idleTimeout;
        }
    }
    ##"Name"=$;
    ##"PhysicalPath"= $;
    ##"AppPoolName" = $key;
    $webApps = Get-WebApplication -Site $iisSiteName;
    $Applications = @();
    
    foreach($app in $webApps){
        $key = $app.applicationPool;
        $Applications += @{
            "Name"=$app.path.Substring(1); #substring out the leading /
            "PhysicalPath"= $app.PhysicalPath;
            "AppPoolName" = $app.applicationPool;
            "UserName" = $appPools[$key].UserName;
            "Password" = $appPools[$key].Password;
            "IdentityType" = $identityType[$appPools[$key].IdentityType];
            "DotNetVersion" = $appPools[$key].DotNetVersion;
            "Pipeline"= $appPools[$key].Pipeline; 
            "RecycleTimes" = $appPools[$key].RecycleTimes;
            "IdleTimeout" = $appPools[$key].IdleTimeout;
        }
    }
    $Result = @{};
    $Result["Applications"] = $Applications | sort-object { $_.Name };
    $Result | ConvertTo-Json | Out-File -filepath C:\temp\$iisSiteName.json;
    #New-Object –TypeNamePSObject –Prop $properties