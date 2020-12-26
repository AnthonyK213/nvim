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
      > External dependencies(MS Windows).
    - `init_deplnx.vim` (Empty so far)
      > External dependencies(GNU/Linux).
    - `init_depmac.vim` (Empty so far)
      > External dependencies(macOS).
  - Utilities
    - `init_fnutil.vim`
      > External cross-platform dependencies(Git, LaTex, etc.);  
      > Functions:
      > - Mouse toggle
      > - Chinese characters count
      > - Bullets auto-insertion
      > - Surrounding pairs
    - `init_subsrc.vim`
      > When don't want to use any plug-ins,  
      > this can be a simple substitute.  
      > Include:
      > - Netrw configuration
      > - Build-in completion
      > - Simple auto-pairing
  - Plug-ins
    - `init_a_plug.vim`
      > Vim-plug load plug-ins.
    - `init_plugrc.vim`; `init_rc_coc.vim`
      > Configurations of plug-ins.(source init_plugin at first)
  - Color schemes
    - `nanovi.vim`
      > Based on [nano-emacs](https://github.com/rougier/nano-emacs) light

## init.vim
``` vim
if !exists('g:init_src')
  let g:init_src = 'full'
endif

if g:init_src ==? 'clean'
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
elseif g:init_src ==? 'light'
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
  source <sfile>:h/init/init_deflib.vim
  source <sfile>:h/init/init_depwin.vim
  source <sfile>:h/init/init_fnutil.vim
  source <sfile>:h/init/init_subsrc.vim
  source <sfile>:h/init/init_nanovi.vim
  source <sfile>:h/init/init_vemacs.vim
elseif g:init_src == 'full'
  source <sfile>:h/init/init_a_plug.vim
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
  source <sfile>:h/init/init_deflib.vim
  source <sfile>:h/init/init_depwin.vim
  source <sfile>:h/init/init_fnutil.vim
  source <sfile>:h/init/init_plugrc.vim
  source <sfile>:h/init/init_rc_coc.vim
  source <sfile>:h/init/init_vemacs.vim
endif
```

## Key bindings
* Customized
* Emacs shit
* Windows shit
* Functional utilities
* Plug-in

## Commands
