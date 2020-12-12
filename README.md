# Neovim Configuration

## Dependencies
* **Python**
  > pip install pynvim  
  > pip install neovim-remote
* **Node.js**
  > npm install yarn -g  
  > npm install neovim -g
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
  - Utilities
    - `init_myutil.vim`
      > External cross-platform dependencies(Git, LaTex, etc.);
      > Functions:
      > - Mouse toggle
      > - Chinese character count
    - `init_pairau.vim`
      > Going to make it a decent plug-in.
      > Functions:
      > - Auto pairs
      > - Pairs Surrounding
    - `init_subsrc.vim`
      > When don't want to use any plug-in.(conflict with plugrc)
  - Platforms
    - `init_depwin.vim`
      > External dependencies(Microsoft Windows).
    - `init_depwsl.vim`
      > External dependencies(Windows Subsystem for Linux).
  - Plug-ins
    - `init_plugin.vim`
      > Vim-plug load plug-ins.
    - `init_plugrc.vim`
      > Configurations of plug-ins.(source init_plugin at first)
  - Color schemes
    - `one_dark.vim`
    - `monokai.vim`

## init.vim
``` vim
source <sfile>:h/init/init_basics.vim
source <sfile>:h/init/init_custom.vim
source <sfile>:h/init/init_deflib.vim
source <sfile>:h/init/init_depwin.vim
source <sfile>:h/init/init_myutil.vim
source <sfile>:h/init/init_pairau.vim
"source <sfile>:h/init/init_plugin.vim
"source <sfile>:h/init/init_plugrc.vim
source <sfile>:h/init/init_subsrc.vim

source <sfile>:h/themes/one_dark.vim
"source <sfile>:h/themes/monokai.vim
```
