$Folders = Get-ChildItem | ?{ $_.PSIsContainer } | Where-Object {$_.FullName -ne "C:\Windows"};
#$Folders = Get-ChildItem | ?{ $_.PSIsContainer };
$Folders2 = @();

foreach($f in $Folders){
    $Folders2 += Get-ChildItem -Path $Folders.FullName | ?{ $_.PSIsContainer };
}
Write-Output $Folders2;

$results = @();
foreach ($folder in $Folders2.GetEnumerator()) {
    $r = New-Object PSObject;
    $r | Add-Member NoteProperty IName( $folder.FullName);
    $r | Add-Member NoteProperty ISize( ((Get-ChildItem $folder -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB));
    $results += $r;
}

$results = $results | Sort-Object -Descending -Property ISize;
foreach ($result in $results){
    "{1:N2} GB - {0}" -f ($result.IName, $result.ISize);
}