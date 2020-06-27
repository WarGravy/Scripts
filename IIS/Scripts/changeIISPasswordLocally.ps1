Param
    (
        [bool]
        $update = $false
    )


#MAIN START
$credentials = (Get-Credential -Message "Please enter the Service Account credentials including Domain Name").GetNetworkCredential();
#Prompt user for credentials and to continue in the case the update switch is on.
if($update){
    Write-Host "The update switch is set to true, this script will attempt to overrwrite credentials...";
    $choice = Read-Host "Enter 'C' to continue, anything else will exit the script.";
    if($choice -ne "C"){
        exit
    }
}

Write-Host "Remoting to machine $computerFQDN ...";
Import-Module WebAdministration
    $username = $credentials.Domain + '\' + $credentials.UserName;

    #Get all App Pools
    $appPools = Get-Item "IIS:\AppPools\";
    $appPools = $appPools.Children;
    #iterate through each app pool, write out app pool name for each matching app pool
    Write-Host "Updating credentials for the following application pools using the service account $username ...";
    $appNames = @();
    foreach($pool in $appPools.GetEnumerator()){
        $appNames += $pool.key;
    }
    
    foreach($name in $appNames)
    {
        $p = Get-Item "IIS:\AppPools\$name";
        if($username -eq $p.processModel.userName)
        {
            Write-Host $name;
            if($update){
                Set-ItemProperty "IIS:\AppPools\$name" -name processModel.identityType -Value SpecificUser 
                Set-ItemProperty "IIS:\AppPools\$name" -name processModel.userName -Value $username
                Set-ItemProperty "IIS:\AppPools\$name" -name processModel.password -Value $credentials.Password
            }
        }
    }