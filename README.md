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
   * Copy all init files into ~/AppData/Local/nvim/.

6. **Install plugins via vim-plug**
   * > :PlugInstall.

7. **Coc plugins**
   * coc-rls
   * coc-python
   * coc-vimtex

## init.vim
> The init.vim is flexible

``` vim
source <sfile>:h/init/init_plugin.vim
source <sfile>:h/init/init_basics.vim
source <sfile>:h/init/init_custom.vim
source <sfile>:h/init/init_fn_lib.vim
source <sfile>:h/init/init_depend.vim
source <sfile>:h/init/init_depwin.vim
source <sfile>:h/init/init_depwsl.vim
source <sfile>:h/init/init_plugrc.vim
source <sfile>:h/init/init_subsrc.vim
source <sfile>:h/themes/one_dark.vim
```
