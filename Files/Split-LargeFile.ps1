PARAM($PATH)
$upperBound = 50MB # calculated by Powershell
$ext = "log"
$rootName = "log_"

$reader = new-object System.IO.StreamReader("$PATH")
$count = 1
$fileName = "{0}{1}.{2}" -f ($rootName, $count, $ext)
while(($line = $reader.ReadLine()) -ne $null)
{
    Add-Content -path $fileName -value $line
    if((Get-ChildItem -path $fileName).Length -ge $upperBound)
    {
        ++$count
        $fileName = "{0}{1}.{2}" -f ($rootName, $count, $ext)
    }
}

$reader.Close()