#!/bin/bash

nvim_dir="$HOME/.local/bin/nvim"
proxy_default="http://127.0.0.1:10809"
source="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
archive="$HOME/.local/bin/nvim-linux64.tar.gz"
backup_dir="$HOME/.local/bin/neovim_backup"

#if [ ! -d "$backup_dir" ]; then
#    mkdir "$backup_dir"
#    echo "New backup directory |neovim_backup| created."
#fi

if [ -d "$nvim_dir" ]; then
    #printf -v name '%(%Y_%m_%d_%H_%M)T' -1
    #mv "$nvim_dir" "$backup_dir/$name"
    rm -r $nvim_dir
fi

if [ -z "$1" ]; then
    echo "Using system proxy or no proxy."
    wget $source -O $archive
elif [ "$1" = "default" ]; then
    echo "Using default proxy."
    curl -L $source -o $archive -x $proxy_default
else
    echo "Using proxy: $1."
    curl -L $source -o $archive -x $1
fi

tar -xf $archive -C "$HOME/.local/bin"
mv "$HOME/.local/bin/nvim-linux64" "$HOME/.local/bin/nvim/"
rm $archive

echo "Neovim nightly has been upgraded."
