# Configuration of Neovim

## Installation
1. **Install Neovim**
   * Download neovim from github repository;
   * Extract the file to the directory wherever you want.
   * Need OneDrive in path to specify the user home directory.

2. **Python support**
   * Must have installed python at first;
   * > pip install pynvim
   * > pip install jedi
   * > pip install neovim-remote

3. **Install node.js**
   * Add node.js binary folder to the path.
   * > npm install yarn
   * > npm install neovim

4. **Manage the plugins by vim-plug**
   * Copy plug.vim into ~/AppData/Local/nvim-data/site/autoload/
   * Create folder to store the plugins: .../nvim-data/plugged/

5. **Set configurations**
   * > cd ~/AppData/Local
   * > git clone git@github.com:AnthonyK213/nvim.git

6. **Install plugins via vim-plug**
   * > :PlugInstall

7. **Coc plugins**
   * coc-rls
   * coc-python
   * coc-vimtex

## init.vim

``` vim
source <sfile>:h/init/init_plugin.vim    " Vim-plug load plug-ins.
source <sfile>:h/init/init_basics.vim    " A simple configuration with no dependencies.
source <sfile>:h/init/init_custom.vim    " Custom functions(key mappings, auto pairing, etc.)
source <sfile>:h/init/init_fn_lib.vim    " Public function library.
source <sfile>:h/init/init_depend.vim    " External cross-platform dependencies(Git, LaTex, etc.).
source <sfile>:h/init/init_depwin.vim    " External dependencies(Microsoft Windows).
source <sfile>:h/init/init_depwsl.vim    " External dependencies(Windows Subsystem for Linux).
source <sfile>:h/init/init_plugrc.vim    " Configurations of plug-ins.(load plugin at first)
source <sfile>:h/init/init_subsrc.vim    " When don't want to use plug-ins.(conflict with plugrc)
source <sfile>:h/themes/one_dark.vim     " Color schemes.(conflict with plugrc)
```
