$nvim_dir = "D:/App/Neovim"
$proxy = "http://127.0.0.1:10809"
$source = "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip"
$archive = "D:/App/nvim-win64.zip"

if (!(Test-Path "D:/App/nvim_bak")) {
    New-Item -ItemType "directory" -Path "D:/App/nvim_bak"
}

if (Test-Path $nvim_dir) {
    $name = Get-Date -Format "yyyy_MM_dd_HH_mm"
    Move-Item -Path $nvim_dir -Destination D:\App\nvim_bak\$name
}

Invoke-WebRequest -Uri $source -OutFile $archive -Proxy $proxy
Expand-Archive -Path $archive -DestinationPath 'D:/App'
Remove-Item -Path $archive