$dir= 'E:\Wallpapers'
add-type -AssemblyName System.Drawing


foreach($pic in Get-ChildItem $dir){
    try{
        $img=[System.Drawing.Image]::FromFile($pic.fullname)
        $resolution="$($img.Width)x$($img.Height)"
        $img.Dispose() 

        $targetFolder=Join-Path $dir $resolution

        if(-not (Test-Path $targetFolder)){
            New-Item $targetFolder -ItemType Directory |Out-Null
        }

        Move-Item $pic.FullName $targetFolder -Force
    }
    catch{
        #it wasn't an image file, nevermind
    }
}