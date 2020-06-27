$TargetServer = read-host "What is your target server name?"
$Userid = read-host "What userid shall we use for logging onto $TargetServer ?"

invoke-command -computername $TargetServer -scriptblock {
   
   get-host
   
   } -credential $Userid