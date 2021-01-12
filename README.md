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
* **Clone source code**
  > git clone https://github.com/AnthonyK213/nvim.git
* **Set** [init.vim](#init.vim)
  - Basics
    - `init_basics.vim`
      > Basic configuration without any dependencies.
    - `init_custom.vim`
      > Global variables and key maps.
    - `init_deflib.vim`
      > Public function library.
  - Utilities
    - `init_fnutil.vim`
      > External cross-platform dependencies(Git, LaTeX, etc.);  
      > Functions:
      > - Surrounding pairs
      > - Chinese characters count
      > - Search cword or selection in system default browser
      > - Bullets auto-insertion and auto-arrangement
      > - LaTeX compile recipes
      > - Git lazy push(commit all and push all)
      > - Compile and run code of current buffer
      > - View pdf in system default viewer
      > - Append orgmode style time stamp to the end of current line
      > - Append day of week after a date string(yyyy-mm-dd)
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
    - `init_plugrc.vim`
      > Configurations of plug-ins.(source init_plugin at first)
  - Color schemes
    - `nanovim.vim`
      > Based on [nano-emacs](https://github.com/rougier/nano-emacs)


## init.vim
* Example
``` vim
if !exists('g:init_src')
  let g:init_src = 'full'
endif

if g:init_src ==? 'clean'
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
elseif g:init_src ==? 'nano'
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
  source <sfile>:h/init/init_deflib.vim
  source <sfile>:h/init/init_fnutil.vim
  source <sfile>:h/init/init_subsrc.vim
  set background=light
  colorscheme nanovim
elseif g:init_src == 'full'
  source <sfile>:h/init/init_a_plug.vim
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
  source <sfile>:h/init/init_deflib.vim
  source <sfile>:h/init/init_fnutil.vim
  source <sfile>:h/init/init_plugrc.vim
endif
```


## Key bindings
* Customized
  - `<leader>` is mapped to `<space>`.
  - n:   `<C-j>`      -> Indent entire line toward left.
  - n:   `<C-k>`      -> Indent entire line toward right.
  - n:   `<C-Direct>` -> Adjust window size.
  - n:   `<M-,>`      -> Open init.vim.
  - t:   `<M-d>`      -> Close the terminal.
  - nv:  `<M-f>`      -> Find and replace.
  - inv: `<M-h>`      -> Jump to the window left.
  - inv: `<M-j>`      -> Jump to the window below.
  - inv: `<M-k>`      -> Jump to the window above.
  - inv: `<M-l>`      -> Jump to the window right.
  - inv: `<M-w>`      -> Jump to the window in turn.
  - in:  `<M-Number>` -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
  - n:   `<leader>b`+ -> Buffer.
    - `n`: Next buffer.
    - `p`: Previous buffer.
    - `d`: Delete buffer.
  - n:   `<leader>cd` -> Set directory to the current buffer.
  - n:   `<leader>nh` -> Turn off highlights.
  - n:   `<leader>sc` -> Toggle spell check status.
* Functional utilities
  - iv:  `<M-p>`      -> backquote surround.
  - iv:  `<M-i>`      -> single asterisk surround.
  - iv:  `<M-b>`      -> double asterisk surround.
  - iv:  `<M-m>`      -> treble asterisk surround.
  - iv:  `<M-u>`      -> `<u></u>` surround.
  - v:   `<leader>e`  -> Surrounding.
    - `(`: ( )
    - `[`: [ ]
    - `{`: { }
    - `'`: ' '
    - `"`: " "
    - `<`: < >
    - `$`: $ $
  - v:   `<leader>vs` -> Git status.
  - invt:`<F2>`       -> Toggle mouse status.
  - in:  `<F5>`       -> Toggle background.
  - nv:  `<leader>wc` -> Chinese characters count.
  - v:   `*`          -> Search visual selection.
  - i:   `<M-CR>`     -> Auto insert bullet.
  - n:   `<leader>sl` -> Sort number list.
  - nv:  `<leader>f`  -> Search text in web browser.
    - `b`: Baidu
    - `g`: Google
    - `h`: Github
    - `y`: Youdao
  - n:   `<C-c><C-c>` -> Insert time stamp at the end of line.
  - n:   `<C-c><C-d>` -> Append day of week to the end of a date string(yyyy-mm-dd) under the cursor.
* System
  - in:  `<M-t>`      -> Open system terminal.
  - in:  `<C-s>`      -> Save.
  - in:  `<C-z>`      -> Undo.
  - v:   `<M-c>`      -> Copy to system clipboard.
  - v:   `<M-x>`      -> Cut to system clipboard.
  - inv: `<M-v>`      -> Paste from system clipboard.
  - in:  `<M-a>`      -> Select all.
  - in:  `<F4>`       -> Open system file manager.
* Emacs shit
  - inv: `<C-n>`      -> Emacs next.
  - inv: `<C-p>`      -> Emacs previous.
  - i:   `<C-f>`      -> Emacs forward.
  - i:   `<C-b>`      -> Emacs backward.
  - i:   `<C-a>`      -> Emacs line start.
  - i:   `<C-e>`      -> Emacs line end.
  - i:   `<C-k>`      -> Emacs kill test on the right.
  - i:   `<C-SPACE>`  -> Emacs set mark.
  - i:   `<M-f>`      -> Emacs next word.
  - i:   `<M-b>`      -> Emacs last word.
  - in:  `<M-x>`      -> Command line.
  - i:   `<M-d>`      -> Emacs delete word.
* Plug-in
  - int: `<F3>`       -> NERDTree toggle.
  - int: `<M-n>`      -> NERDTree focus.
  - n:   `<leader>h`  -> Signify.
    - `j`: Next hunk.
    - `k`: Previous hunk.
    - `J`: Last hunk.
    - `K`: First hunk.
    - `t`: Signify toggle.
  - n:   `<leader>m`  -> vim-markdown
    - `h`: Toc horizontal.
    - `v`: Toc vertical.
    - `m`: Toggle math syntax.
  - n:   `<leader>t`  -> vim-table-mode
    - `a`: Add formula.
    - `f`: Re-align.
    - `c`: Evaluate formula.
  - coc.nvim

## Commands
- Functional utilities
  - `Xe1`: Compile with XeLaTeX for one time.
  - `Xe2`: Compile with XeLaTeX for two times.
  - `Bib`: Compile with biber.
  - `PushAll`: Just push all to the remote origin.
    - `-b`: branch, default value is current branch.
    - `-m`: comment, default value is the date.
  - `CodeRun`: Run code of current buffer.
  - `Time`: Echo date and time.
  - `PDF`: Open pdf with the given name in the system viewer.
           Without name given, the name will be set at the file of the current buffer.
- Plug-in
  - `OrgAgenda`: Open org agenda.
  - coc.nvim
