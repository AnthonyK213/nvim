param ($proxy)

$env_vim  = $env:VIM
$nvim_dir = (Get-Item -Force $env_vim).Parent.Parent.FullName
$app_dir  = (Get-Item -Force $nvim_dir).Parent.FullName
$nvim_bak = "$app_dir\neovim_backup"
$archive  = "$app_dir\nvim-win64.zip"

$source = "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip"
$proxy_default = "http://127.0.0.1:10809"

if (!(Test-Path "D:/App/neovim_backup")) {
    New-Item -ItemType "directory" -Path $nvim_bak | Out-Null
    Write-Host "New backup directory |neovim_backup| created."
}

if (Test-Path $nvim_dir) {
    $update_time = Get-Date -Format "yyyy_MM_dd_HH_mm"
    $version_info = ""
    if ($(nvim --version)[0] -match '^NVIM (?<version>v\d\.\d\.\d)-dev\+(?<number>\d+)-(?<detail>.+)$') {
        $version_info = $Matches.number
    }
    $name = $version_info + '-' + $update_time
    Move-Item -Path $nvim_dir -Destination $nvim_bak\$name
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


Expand-Archive -Path $archive -DestinationPath $app_dir
Remove-Item -Path $archive

Write-Host "Neovim nightly has been upgraded."
