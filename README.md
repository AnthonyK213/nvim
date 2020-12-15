# Neovim Configuration

## Dependencies
* **Node.js**(to use coc.nvim & markdown-preview)
  > npm install yarn -g  
  > npm install neovim -g
* **Python**(to use vim-orgmode)
  > pip install pynvim  
  > pip install neovim-remote
* **vim-plug**
  - Windows
    - Set plug.vim into
      > ~/AppData/Local/nvim-data/site/autoload/
    - Plug-in directory
      > ~/AppData/Local/nvim-data/plugged/
  - GNU/Linux
    - Set plug.vim into
      > ~/.local/share/nvim/site/autoload/

## Install
* **Configuration Directory**
  - Windows
    > cd ~/AppData/Local/
  - GNU/Linux
    > cd ~/.config/
* **Git clone**
  > git clone git@github.com:AnthonyK213/nvim.git
* **Set** [init.vim](#init.vim)
  - Basics
    - `init_basics.vim`
      > Basic configuration without any dependencies.
    - `init_custom.vim`
      > Global variables and key maps.
    - `init_deflib.vim`
      > Public function library.
  - Platforms
    - `init_depwin.vim`
      > External dependencies(Microsoft Windows).
    - `init_depwsl.vim`
      > External dependencies(Windows Subsystem for Linux).
  - Utilities
    - `init_fnutil.vim`
      > External cross-platform dependencies(Git, LaTex, etc.);  
      > Functions:
      > - Mouse toggle
      > - Chinese character count
    - `init_subsrc.vim`
      > When don't want to use any plug-ins,  
      > this can be a simple substitute.  
      > Include:
      > - Netrw configuration
      > - Build-in completion
  - Plug-ins
    - `init_a_plug.vim`
      > Vim-plug load plug-ins.
    - `init_plugrc.vim`; `init_rc_coc.vim`
      > Configurations of plug-ins.(source init_plugin at first)
  - Color schemes
    - `onedark.vim`
    - `monokai.vim`

## init.vim
``` vim
"source <sfile>:h/init/init_a_plug.vim
source <sfile>:h/init/init_basics.vim
source <sfile>:h/init/init_custom.vim
source <sfile>:h/init/init_deflib.vim
source <sfile>:h/init/init_depwin.vim
source <sfile>:h/init/init_fnutil.vim
"source <sfile>:h/init/init_plugrc.vim
"source <sfile>:h/init/init_rc_coc.vim
source <sfile>:h/init/init_subsrc.vim
source <sfile>:h/scheme/onedark.vim
"source <sfile>:h/scheme/monokai.vim
```
