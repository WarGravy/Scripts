PARAM([STRING]$Uri)
$Result = Invoke-WebRequest -Uri $Uri -Method Post