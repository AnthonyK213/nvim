# Neovim Configuration


## Requirements
* **Neovim nightly build**
* **Python**(for vim-orgmode)
  > pip install pynvim  
  > pip install neovim-remote
* **paq-nvim**
  - Windows
    - Clone paq-nvim into
      > %localappdata%/nvim-data/site/pack/paqs/opt/paq-nvim
  - GNU/Linux
    ```bash
    git clone https://github.com/savq/paq-nvim.git \
        "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim
    ```


## Install
* **Configuration Directory**
  - Windows
    > %localappdata%/nvim
  - GNU/Linux
    > ~/.config/nvim
* **Clone source code**
  ```bash
  git clone https://github.com/AnthonyK213/nvim.git
  ```
* **Set init.lua**
  - Lua module
    - `internal`
      - Variables.
      - Mappings.
      - Commands.
    - `package`
      - Paq-nvim managed plug-ins.
      - Configurations of plug-ins.
      - UI configuration.
    - `utility`
      - Public function library.
  - VimL
    - `init_basics.vim`
      - Basic configuration without any dependencies.
    - `init_subsrc.vim`
      - When don't want to use any plug-ins, this can be a simple substitute.
      - Include:
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
  - int: `<M-e>`      -> *nerdtree*, NERDTree focus.
  - nv:  `<M-f>`      -> Find and replace.
  - inv: `<M-h>`      -> Jump to the window left.
  - inv: `<M-j>`      -> Jump to the window below.
  - inv: `<M-k>`      -> Jump to the window above.
  - inv: `<M-l>`      -> Jump to the window right.
  - nv:  `<M-n>`      -> Normal command.
  - inv: `<M-v>`      -> Paste from system clipboard.
  - inv: `<M-w>`      -> Jump to the window in turn.
  - v:   `<M-x>`      -> Cut to system clipboard.
  - n:   `<M-,>`      -> Open init.lua.
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
  - i:   `<M-f>`      -> Emacs next word.
  - i:   `<M-b>`      -> Emacs last word.
  - in:  `<M-x>`      -> Command line.
  - i:   `<M-d>`      -> Emacs delete word.
* **Leader**
  > `<leader>` is mapped to `<SPACE>`.
  - `<leader>b` -> **Buffer**.
    - n:    `b` -> *nvim-bufferline.lua*, BufferLinePick.
    - n:    `c` -> Set directory to the current buffer.
    - n:    `d` -> Delete buffer.
    - n:    `g` -> Toggle background.
    - n:    `h` -> Turn off highlights.
    - n:    `n` -> Next buffer.
    - n:    `p` -> Previous buffer.
    - n:    `x` -> *fzf.vim*, switch buffer using fzf.
  - `<leader>c` -> **Check**.
    - nv:   `c` -> Chinese characters count.
    - n:    `s` -> Toggle spell check status.
  - `<leader>d` -> **Date**
    - n:    `s` -> Insert time stamp at the end of line.
    - n:    `d` -> Append day of week to the end of a date string(yyyy-mm-dd) under the cursor.
  - `<leader>f` -> FZF
    - n:    `f` -> *fzf.vim*, fzf  (:Files)
    - n:    `g` -> *fzf.vim*, ripgrep (:Rg)
  - `<leader>k` -> **Search text in web browser**.
    - nv:   `b` -> Baidu
    - nv:   `g` -> Google
    - nv:   `h` -> Github
    - nv:   `y` -> Youdao
  - `<leader>m` -> **vim-markdown**
    - n:    `l` -> Sort number list.
    - n:    `m` -> *vim-markdown*, Toggle math syntax.
    - n:    `h` -> *vim-markdown*, Toc horizontal.
    - n:    `v` -> *vim-markdown*, Toc vertical.
  - `<leader>o` -> **Open**.
    - n:    `b` -> Open file of buffer with system default browser.
    - n:    `e` -> Open system file manager.
    - nt:   `p` -> *nerdtree*, NERDTree toggle.
    - n:    `t` -> Open terminal.
  - `<leader>s` -> **Surrounding**.
    - nv:   `a` -> Surrounding add.
    - n:    `c` -> Surrounding change.
    - n:    `d` -> Surrounding delete.
  - `<leader>t` -> **vim-table-mode**
    - n:    `a` -> *vim-table-mode*, Add formula.
    - n:    `c` -> *vim-table-mode*, Evaluate formula.
    - n:    `f` -> *vim-table-mode*, Re-align.
  - `<leader>v` -> **VCS**.
    - n:    `j` -> *vim-signify*, Next hunk.
    - n:    `k` -> *vim-signify*, Previous hunk.
    - n:    `J` -> *vim-signify*, Last hunk.
    - n:    `K` -> *vim-signify*, First hunk.
    - n:    `s` -> Git status.
    - n:    `t` -> *vim-signify*, Signify toggle.
* **Misc**
  - v:   `*`    -> Search visual selection.
  - invt:`<F2>` -> Toggle mouse status.

## Commands
- Functional utilities
  - `Bib`: Compile with biber.
  - `CodeRun`: Run code of current buffer.
  - `Eval`: Evaluate formula(lua) surrounded by backquotes.
  - `OrgAgenda`: *vim-orgmode*, Open org agenda.
  - `PDF`: Open pdf with the same name of the buffer file in the same directory.
  - `PushAll`: Just push all to the remote origin.
    - `-b`: branch, current branch default.
    - `-m`: comment, the date default.
  - `Time`: Echo date and time.
  - `Xe1`: Compile with XeLaTeX for one time.
  - `Xe2`: Compile with XeLaTeX for two times.
