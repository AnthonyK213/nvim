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
      > Include some functions and key maps.  
      > Functions:
      > - Mouse toggle
      > - Auto pairs
      > - Surround
      > - Chinese character count
    - `init_fn_lib.vim`
      > Public function library.
  - Cooperate with external dependencies
    - `init_depend.vim`
      > External cross-platform dependencies(Git, LaTex, etc.).
    - `init_depwin.vim`
      > External dependencies(Microsoft Windows).
    - `init_depwsl.vim`
      > External dependencies(Windows Subsystem for Linux).
    - `init_subsrc.vim`
      > When don't want to use any plug-in.(conflict with plugrc)
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
source <sfile>:h/init/init_fn_lib.vim
source <sfile>:h/init/init_custom.vim
source <sfile>:h/init/init_depend.vim
source <sfile>:h/init/init_depwin.vim
source <sfile>:h/init/init_aupair.vim
source <sfile>:h/init/init_subsrc.vim
"source <sfile>:h/init/init_plugin.vim
"source <sfile>:h/init/init_plugrc.vim

source <sfile>:h/themes/one_dark.vim
"source <sfile>:h/themes/monokai.vim
```
