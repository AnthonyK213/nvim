#!/bin/bash

nvim_dir="$HOME/.local/bin/nvim"
archive="$HOME/.local/bin/nvim-linux64.tar.gz"

source="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
proxy_default="http://127.0.0.1:10809"

if [ -d "$nvim_dir" ]; then
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
mv "$HOME/.local/bin/nvim-linux64" $nvim_dir
rm $archive

echo "Neovim nightly has been upgraded."
