param ($proxy)

$nvim_dir = "D:/App/Neovim"
$proxy_default = "http://127.0.0.1:10809"
$source = "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip"
$archive = "D:/App/nvim-win64.zip"

if (!(Test-Path "D:/App/neovim_backup")) {
    New-Item -ItemType "directory" -Path "D:/App/neovim_backup" | Out-Null
    Write-Host "New backup directory |neovim_backup| created."
}

if (Test-Path $nvim_dir) {
    $name = Get-Date -Format "yyyy_MM_dd_HH_mm"
    Move-Item -Path $nvim_dir -Destination D:\App\neovim_backup\$name
}


if ($proxy -eq $null) {
    Write-Host "Using system proxy or no proxy."
    Invoke-WebRequest -Uri $source -OutFile $archive
} elseif ($proxy -eq "default") {
    Write-Host "Using default proxy."
    Invoke-WebRequest -Uri $source -OutFile $archive -Proxy $proxy_default
} else {
    Write-Host "Using proxy: $proxy."
    Invoke-WebRequest -Uri $source -OutFile $archive -Proxy $proxy
}


Expand-Archive -Path $archive -DestinationPath "D:/App"
Remove-Item -Path $archive

Write-Host "Neovim nightly has been upgraded."
