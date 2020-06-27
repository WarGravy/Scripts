    Import-Module WebAdministration;
    $appPools = Get-Item "IIS:\AppPools\";
    $appPools = $appPools.Children;
    
    
    $appNames = @();
    foreach($pool in $appPools.GetEnumerator()){
        $appNames += $pool.key;
    }
    
    $pools = @();
    foreach($appName in $appNames){
        $pools += Get-Item "IIS:\AppPools\$appName";
    }
    $pools | ConvertTo-Json | Out-File -filepath C:\temp\appPools.json;