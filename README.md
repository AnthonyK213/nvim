# Neovim Configuration


## Requirements
* **Neovim nightly build**
* **Python**(for vim-orgmode)
  > pip install pynvim  
  > pip install neovim-remote
* [**ripgrep**](https://github.com/BurntSushi/ripgrep)(for fzf.vim)
  - Crazy fast search tool.
* **[paq-nvim](https://github.com/savq/paq-nvim)**
  - Windows
    - Clone paq-nvim into
      > %localappdata%/nvim-data/site/pack/paqs/opt/paq-nvim
  - GNU/Linux
    ```bash
    git clone https://github.com/savq/paq-nvim.git \
        "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim
    ```


## Installation
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
    - `viml_basics.vim`
      - Basic configuration without any dependencies.
    - `viml_subsrc.vim`
      - When don't want to use any plug-ins, this can be a simple substitute.
  - Color schemes
    - `nanovim.vim`
      - Based on [nano-emacs](https://github.com/rougier/nano-emacs)


## Key bindings
* **Ctrl**
  - n:   <kbd>C-j</kbd>      -> Indent left.
  - n:   <kbd>C-k</kbd>      -> Indent right.
  - in:  <kbd>C-s</kbd>      -> Save.
  - in:  <kbd>C-z</kbd>      -> Undo.
  - n:   <kbd>C-Direct</kbd> -> Adjust window size.
* **Meta**
  - in:  <kbd>M-a</kbd>      -> Select all.
  - v:   <kbd>M-c</kbd>      -> Copy to system clipboard.
  - t:   <kbd>M-d</kbd>      -> Close the terminal.
  - int: <kbd>M-e</kbd>      -> *nerdtree*, NERDTree focus.
  - nv:  <kbd>M-f</kbd>      -> Find and replace.
  - inv: <kbd>M-h</kbd>      -> Jump to the window left.
  - inv: <kbd>M-j</kbd>      -> Jump to the window below.
  - inv: <kbd>M-k</kbd>      -> Jump to the window above.
  - inv: <kbd>M-l</kbd>      -> Jump to the window right.
  - nv:  <kbd>M-n</kbd>      -> Normal command.
  - inv: <kbd>M-v</kbd>      -> Paste from system clipboard.
  - inv: <kbd>M-w</kbd>      -> Jump to the window in turn.
  - v:   <kbd>M-x</kbd>      -> Cut to system clipboard.
  - n:   <kbd>M-,</kbd>      -> Open init.lua.
  - i:   <kbd>M-CR</kbd>     -> Auto insert bullet.
  - in:  <kbd>M-Number</kbd> -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
* **Emacs shit**
  - inv: <kbd>C-n</kbd>      -> Emacs next.
  - inv: <kbd>C-p</kbd>      -> Emacs previous.
  - i:   <kbd>C-f</kbd>      -> Emacs forward.
  - i:   <kbd>C-b</kbd>      -> Emacs backward.
  - i:   <kbd>C-a</kbd>      -> Emacs line start.
  - i:   <kbd>C-e</kbd>      -> Emacs line end.
  - i:   <kbd>C-k</kbd>      -> Emacs kill test on the right.
  - i:   <kbd>M-f</kbd>      -> Emacs next word.
  - i:   <kbd>M-b</kbd>      -> Emacs last word.
  - in:  <kbd>M-x</kbd>      -> Command line.
  - i:   <kbd>M-d</kbd>      -> Emacs delete word.
* **Leader**
  > <kbd>leader</kbd> is mapped to <kbd>SPACE</kbd>.
  - <kbd>leader-b-</kbd>     -> **Buffer**.
    - n:    <kbd>b</kbd>     -> *nvim-bufferline.lua*, BufferLinePick.
    - n:    <kbd>c</kbd>     -> Set directory to the current buffer.
    - n:    <kbd>d</kbd>     -> Delete buffer.
    - n:    <kbd>g</kbd>     -> Toggle background.
    - n:    <kbd>h</kbd>     -> Turn off highlights.
    - n:    <kbd>n</kbd>     -> Next buffer.
    - n:    <kbd>p</kbd>     -> Previous buffer.
    - n:    <kbd>x</kbd>     -> *fzf.vim*, switch buffer using fzf.
  - <kbd>leader-c-</kbd>     -> **Check**.
    - nv:   <kbd>c</kbd>     -> Chinese characters count.
    - n:    <kbd>s</kbd>     -> Toggle spell check status.
  - <kbd>leader-d-</kbd>     -> **Date**
    - n:    <kbd>s</kbd>     -> Insert time stamp at the end of line.
    - n:    <kbd>d</kbd>     -> Append day of week to the end of a date string(yyyy-mm-dd) under the cursor.
  - <kbd>leader-e-</kbd>     -> **Evaluate**
    - n:    <kbd>v</kbd>     -> Evaluate lua chunk surrounded by backquote.
    - n:    <kbd>l</kbd>     -> Evaluate lisp chunk(math) surrounded by backquote.
  - <kbd>leader-f-</kbd>     -> FZF
    - n:    <kbd>f</kbd>     -> *fzf.vim*, fzf  (:Files)
    - n:    <kbd>g</kbd>     -> *fzf.vim*, ripgrep (:Rg)
  - <kbd>leader-g-</kbd>     -> **LSP**
    - n:    <kbd>0</kbd>     -> vim.lsp.buf.document_symbol()
    - n:    <kbd>a</kbd>     -> vim.lsp.buf.code_action()
    - n:    <kbd>d</kbd>     -> vim.lsp.buf.declaration()
    - n:    <kbd>f</kbd>     -> vim.lsp.buf.definition()
    - n:    <kbd>h</kbd>     -> vim.lsp.buf.signature_help()
    - n:    <kbd>i</kbd>     -> vim.lsp.buf.implementation()
    - n:    <kbd>r</kbd>     -> vim.lsp.buf.references()
    - n:    <kbd>t</kbd>     -> vim.lsp.buf.type_definition()
    - n:    <kbd>w</kbd>     -> vim.lsp.buf.workspace_symbol()
    - n:    <kbd>[</kbd>     -> vim.lsp.diagnostic.goto_prev()
    - n:    <kbd>]</kbd>     -> vim.lsp.diagnostic.goto_next()
  - <kbd>leader-k-</kbd>     -> **Search text in web browser**.
    - nv:   <kbd>b</kbd>     -> Baidu
    - nv:   <kbd>g</kbd>     -> Google
    - nv:   <kbd>h</kbd>     -> Github
    - nv:   <kbd>y</kbd>     -> Youdao
  - <kbd>leader-m-</kbd>     -> **vim-markdown**
    - n:    <kbd>l</kbd>     -> Sort number list.
    - n:    <kbd>m</kbd>     -> *vim-markdown*, Toggle math syntax.
    - n:    <kbd>h</kbd>     -> *vim-markdown*, Toc horizontal.
    - n:    <kbd>v</kbd>     -> *vim-markdown*, Toc vertical.
  - <kbd>leader-o-</kbd>     -> **Open**.
    - n:    <kbd>b</kbd>     -> Open file of buffer with system default browser.
    - n:    <kbd>e</kbd>     -> Open system file manager.
    - nt:   <kbd>p</kbd>     -> *nerdtree*, NERDTree toggle.
    - n:    <kbd>t</kbd>     -> Open terminal.
  - <kbd>leader-s-</kbd>     -> **Surrounding**.
    - nv:   <kbd>a</kbd>     -> Surrounding add.
    - n:    <kbd>c</kbd>     -> Surrounding change.
    - n:    <kbd>d</kbd>     -> Surrounding delete.
  - <kbd>leader-t-</kbd>     -> **vim-table-mode**
    - n:    <kbd>a</kbd>     -> *vim-table-mode*, Add formula.
    - n:    <kbd>c</kbd>     -> *vim-table-mode*, Evaluate formula.
    - n:    <kbd>f</kbd>     -> *vim-table-mode*, Re-align.
  - <kbd>leader-v-</kbd>     -> **VCS**.
    - n:    <kbd>j</kbd>     -> *vim-signify*, Next hunk.
    - n:    <kbd>k</kbd>     -> *vim-signify*, Previous hunk.
    - n:    <kbd>J</kbd>     -> *vim-signify*, Last hunk.
    - n:    <kbd>K</kbd>     -> *vim-signify*, First hunk.
    - n:    <kbd>s</kbd>     -> Git status.
    - n:    <kbd>t</kbd>     -> *vim-signify*, Signify toggle.
* **Misc**
  - v:   <kbd>*</kbd>        -> Search visual selection.
  - invt:<kbd>F2</kbd>       -> Toggle mouse status.

## Commands
- Functional utilities
  - `Bib`       : Compile with biber.
  - `CodeRun`   : Run code of current buffer.
  - `OrgAgenda` : *vim-orgmode*, Open org agenda.
  - `PDF`       : Open pdf with the same name of the buffer file in the same directory.
  - `PushAll`   : Just push all to the remote origin.
    - `-b`      : branch, current branch default.
    - `-m`      : comment, the date default.
  - `Time`      : Echo date and time.
  - `Xe1`       : Compile with XeLaTeX for one time.
  - `Xe2`       : Compile with XeLaTeX for two times.
