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
  > git clone https://github.com/AnthonyK213/nvim.git -b viml
* **Set init.vim**
  - Basics
    - `init_basics.vim`
      - Basic configuration without any dependencies.
    - `init_custom.vim`
      - Global variables and key maps.
    - `init_deflib.vim`
      - Public function library.
  - Utilities
    - `init_fnutil.vim`
      - External cross-platform dependencies(Git, LaTeX, etc.)
      - Functions:
        - Surrounding(Add, delete & change)
        - Chinese characters count
        - Search cword or selection in system default browser
        - Bullets auto-insertion and auto-arrangement
        - LaTeX compile recipes
        - Git lazy push(Commit all and push all)
        - Compile and run code of current buffer
        - View pdf in system default viewer
        - Append orgmode style time stamp to the end of current line
        - Append day of week after a date string(yyyy-mm-dd)
    - `init_subsrc.vim`
      - When don't want to use any plug-ins, this can be a simple substitute.
      - Include:
        - Netrw configuration
        - Build-in completion
        - Simple auto-pairing
  - Plug-ins
    - `init_a_plug.vim`
      - Vim-plug load plug-ins.
    - `init_plugrc.vim`
      - Configurations of plug-ins.(source init_plugin at first)
  - Color schemes
    - `nanovim.vim`
      - Based on [nano-emacs](https://github.com/rougier/nano-emacs)


## Key bindings
* **Ctrl**
  - n:   `<C-j>`      -> Indent left.
  - n:   `<C-k>`      -> Indent right.
  - in:  `<C-s>`      -> Save.
  - in:  `<C-z>`      -> Undo.
  - n:   `<C-Direct>` -> Adjust window size.
* **Meta**
  - in:  `<M-a>`      -> Select all.
  - v:   `<M-c>`      -> Copy to system clipboard.
  - t:   `<M-d>`      -> Close the terminal.
  - int: `<M-e>`      -> NERDTree focus.
  - nv:  `<M-f>`      -> Find and replace.
  - inv: `<M-h>`      -> Jump to the window left.
  - inv: `<M-j>`      -> Jump to the window below.
  - inv: `<M-k>`      -> Jump to the window above.
  - inv: `<M-l>`      -> Jump to the window right.
  - nv:  `<M-n>`      -> Normal command.
  - inv: `<M-v>`      -> Paste from system clipboard.
  - inv: `<M-w>`      -> Jump to the window in turn.
  - v:   `<M-x>`      -> Cut to system clipboard.
  - n:   `<M-,>`      -> Open init.vim.
  - i:   `<M-CR>`     -> Auto insert bullet.
  - in:  `<M-Number>` -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
* **Emacs shit**
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
* **Leader**
  > `<leader>` is mapped to `<SPACE>`.
  - `<leader>b` -> **Buffer**.
    - n:    `c` -> Set directory to the current buffer.
    - n:    `d` -> Delete buffer.
    - n:    `g` -> Toggle background.
    - n:    `h` -> Turn off highlights.
    - n:    `n` -> Next buffer.
    - n:    `p` -> Previous buffer.
  - `<leader>c` -> **Check**.
    - nv:   `c` -> Chinese characters count.
    - n:    `s` -> Toggle spell check status.
  - `<leader>d` -> **Date**
    - n:    `s` -> Insert time stamp at the end of line.
    - n:    `d` -> Append day of week to the end of a date string(yyyy-mm-dd) under the cursor.
  - `<leader>k` -> **Search text in web browser**.
    - nv:   `b` -> Baidu
    - nv:   `g` -> Google
    - nv:   `h` -> Github
    - nv:   `y` -> Youdao
  - `<leader>m` -> **vim-markdown**
    - n:    `l` -> Sort number list.
    - n:    `m` -> Toggle math syntax.
    - n:    `h` -> Toc horizontal.
    - n:    `v` -> Toc vertical.
  - `<leader>o` -> **Open**.
    - n:    `b` -> Open file of buffer with system default browser.
    - n:    `e` -> Open system file manager.
    - nt:   `p` -> NERDTree toggle.
    - n:    `t` -> Open terminal.
  - `<leader>s` -> **Surrounding**.
    - nv:   `a` -> Surrounding add.
    - n:    `c` -> Surrounding change.
    - n:    `d` -> Surrounding delete.
  - `<leader>t` -> **vim-table-mode**
    - n:    `a` -> Add formula.
    - n:    `c` -> Evaluate formula.
    - n:    `f` -> Re-align.
  - `<leader>v` -> **VCS**.
    - n:    `j` -> Next hunk.
    - n:    `k` -> Previous hunk.
    - n:    `J` -> Last hunk.
    - n:    `K` -> First hunk.
    - n:    `s` -> Git status.
    - n:    `t` -> Signify toggle.
  - `<leader>C` -> **Coc.nvim**
    - n:    `a` -> Do codeAction of current line.
    - n:    `c` -> Fix autofix problem of current line.
    - n:    `f` -> Format selected region.
    - n:    `s` -> Do codeAction of selected region.
    - n:    `r` -> Rename current word.
    - n:    `l` -> *CocList*
      - n:  `a` -> Show all diagnostics.
      - n:  `e` -> Manage extensions.
      - n:  `c` -> Show commands.
      - n:  `o` -> Find symbol of current document.
      - n:  `s` -> Search workspace symbols.
      - n:  `j` -> Do default action for next item.
      - n:  `k` -> Do default action for previous item.
      - n:  `p` -> Resume latest coc list.
* **Misc**
  - v:   `*`    -> Search visual selection.
  - invt:`<F2>` -> Toggle mouse status.

## Commands
- Functional utilities
  - `Xe1`: Compile with XeLaTeX for one time.
  - `Xe2`: Compile with XeLaTeX for two times.
  - `Bib`: Compile with biber.
  - `PushAll`: Just push all to the remote origin.
    - `-b`: branch, current branch default.
    - `-m`: comment, the date default.
  - `CodeRun`: Run code of current buffer.
  - `Time`: Echo date and time.
  - `PDF`: Open pdf with the given name in the system viewer.
           Without name given, the name will be set at the file of the current buffer.
- Plug-in
  - `OrgAgenda`: Open org agenda.
