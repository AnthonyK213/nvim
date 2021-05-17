# Neovim Configuration


## Requirements
* [**Neovim**](https://github.com/neovim/neovim) nightly build
* [**Python**](https://www.python.org/)
  > pip install pynvim  
  > pip install neovim-remote
* [**ripgrep**](https://github.com/BurntSushi/ripgrep)
  - Crazy fast search tool.
* [**paq-nvim**](https://github.com/savq/paq-nvim)
  - Windows
    ```bash
    git clone https://github.com/savq/paq-nvim.git "$env:LOCALAPPDATA\nvim-data\site\pack\paqs\opt\paq-nvim"
    ```
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
* **Set up [lua/core/opt.lua](lua/core/opt_example.lua)**
  - Essential:
    - **dep** -> Dependencies
      - `cc`  -> C compiler
      - `sh`  -> Shell
      - `py3` -> Python3 executable path
    - **path** -> Path
      - `home`    -> Home directory
      - `cloud`   -> Cloud drive directory
      - `desktop` -> Desktop directory
    - **tui** -> Tui
      - `bg`       -> Tui background
      - `material` -> style of material theme
    - **gui** -> Gui (neovim-qt, fvim)
      - `font_half` -> See &gfn
      - `font_full` -> See &gfw
      - `font_size` -> Gui font size
      - `bg`        -> Gui background
  - Optional:
    - **lsp** -> Language Server Protocol
      - `clangd`
      - `jedi_language_server`
      - `omnisharp`
      - `rls`
      - `rust_analyzer`
      - `sumneko_lua`
      - `texlab`
      - `vimls`
    - **ts** -> Treesitter
      - `ensure`     -> Parsers to install automatically
      - `hi_disable` -> File type to disable treesitter highlight


## Modules
- Lua
  - `core`
    - Set up options.
  - `internal`
    - Variables; Mappings; Commands.
  - `package`
    - Paq-nvim managed plug-ins.
    - Configurations of plug-ins.
    - UI configuration.
  - `utility`
    - Public function library.
- VimL
  - `basics.vim`
    - Basic configuration without any dependencies.
  - `subsrc.vim`
    - When no plug-ins installed, this could be a simple substitute.
- Snippet
  - The same as vscode's.
- Color scheme
  - `nanovim.vim`
    - Based on [nano-emacs](https://github.com/rougier/nano-emacs)


## Key bindings
* **Ctrl**
  - in:  <kbd>C-S</kbd>      -> Save.
  - n:   <kbd>C-Direct</kbd> -> Adjust window size.
* **Meta**
  - in:  <kbd>M-a</kbd>      -> Select all.
  - v:   <kbd>M-c</kbd>      -> Copy to system clipboard.
  - t:   <kbd>M-d</kbd>      -> Close the terminal.
  - int: <kbd>M-e</kbd>      -> *nvim-tree.lua*, nvim-tree find file.
  - nv:  <kbd>M-f</kbd>      -> Find and replace.
  - inv: <kbd>M-h</kbd>      -> Jump to the window left.
  - inv: <kbd>M-j</kbd>      -> Jump to the window below.
  - inv: <kbd>M-k</kbd>      -> Jump to the window above.
  - inv: <kbd>M-l</kbd>      -> Jump to the window right.
  - nv:  <kbd>M-n</kbd>      -> Normal command.
  - inv: <kbd>M-v</kbd>      -> Paste from system clipboard.
  - inv: <kbd>M-w</kbd>      -> Jump to the window in turn.
  - v:   <kbd>M-x</kbd>      -> Cut to system clipboard.
  - n:   <kbd>M-,</kbd>      -> Open `$MYVIMRC`.
  - i:   <kbd>M-CR</kbd>     -> Auto insert bullet.
  - in:  <kbd>M-Number</kbd> -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
  - inv: <kbd>M-B</kbd>      -> Markdown **bold**.
  - inv: <kbd>M-I</kbd>      -> Markdown *italic*.
  - inv: <kbd>M-M</kbd>      -> Markdown ***bold_italic***.
  - inv: <kbd>M-P</kbd>      -> Markdown `block`.
  - inv: <kbd>M-U</kbd>      -> Markdown/HTML <u>underscore</u>.
* **Emacs shit**
  - inv: <kbd>C-N</kbd>      -> Emacs next.
  - inv: <kbd>C-P</kbd>      -> Emacs previous.
  - i:   <kbd>C-F</kbd>      -> Emacs forward.
  - i:   <kbd>C-B</kbd>      -> Emacs backward.
  - i:   <kbd>C-A</kbd>      -> Emacs line start.
  - i:   <kbd>C-E</kbd>      -> Emacs line end.
  - i:   <kbd>C-K</kbd>      -> Emacs kill test on the right.
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
  - <kbd>leader-c-</kbd>     -> **Check**.
    - nv:   <kbd>c</kbd>     -> Chinese characters count.
    - n:    <kbd>s</kbd>     -> Toggle spell check status.
  - <kbd>leader-d-</kbd>     -> **Date**.
    - n:    <kbd>s</kbd>     -> Insert time stamp at the end of line.
    - n:    <kbd>d</kbd>     -> Append the day of week to yyyy-mm-dd.
  - <kbd>leader-e-</kbd>     -> **Evaluate**.
    - n:    <kbd>v</kbd>     -> Evaluate lua chunk surrounded by backquote.
    - n:    <kbd>l</kbd>     -> Evaluate lisp chunk(math) surrounded by backquote.
  - <kbd>leader-f-</kbd>     -> **Find**.
    - n:    <kbd>b</kbd>     -> *telescope.nvim*, buffers.
    - n:    <kbd>f</kbd>     -> *telescope.nvim*, find_files.
    - n:    <kbd>g</kbd>     -> *telescope.nvim*, live_grep.
  - <kbd>leader-g-</kbd>     -> **LSP**
    - n:    <kbd>0</kbd>     -> `vim.lsp.buf.document_symbol()`
    - n:    <kbd>a</kbd>     -> `vim.lsp.buf.code_action()`
    - n:    <kbd>d</kbd>     -> `vim.lsp.buf.declaration()`
    - n:    <kbd>f</kbd>     -> `vim.lsp.buf.definition()`
    - n:    <kbd>h</kbd>     -> `vim.lsp.buf.signature_help()`
    - n:    <kbd>i</kbd>     -> `vim.lsp.buf.implementation()`
    - n:    <kbd>r</kbd>     -> `vim.lsp.buf.references()`
    - n:    <kbd>t</kbd>     -> `vim.lsp.buf.type_definition()`
    - n:    <kbd>w</kbd>     -> `vim.lsp.buf.workspace_symbol()`
    - n:    <kbd>[</kbd>     -> `vim.lsp.diagnostic.goto_prev()`
    - n:    <kbd>]</kbd>     -> `vim.lsp.diagnostic.goto_next()`
  - <kbd>leader-h-</kbd>     -> **VCS**.
    - n:    <kbd>j</kbd>     -> *gitsigns.nvim*, next hunk.
    - n:    <kbd>k</kbd>     -> *gitsigns.nvim*, previous hunk.
    - n:    <kbd>p</kbd>     -> *gitsigns.nvim*, preview hunk.
    - n:    <kbd>b</kbd>     -> *gitsigns.nvim*, blame line.
    - n:    <kbd>h</kbd>     -> Git status.
  - <kbd>leader-k-</kbd>     -> **Search text in web browser**.
    - nv:   <kbd>b</kbd>     -> Baidu
    - nv:   <kbd>g</kbd>     -> Google
    - nv:   <kbd>h</kbd>     -> Github
    - nv:   <kbd>y</kbd>     -> Youdao
  - <kbd>leader-l-</kbd>     -> **Comment**.
    - nv:   <kbd>a</kbd>     -> Comment line/block.
    - nv:   <kbd>d</kbd>     -> Un-comment line/block.
  - <kbd>leader-m-</kbd>     -> **Markdown**
    - n:    <kbd>l</kbd>     -> Sort number list.
    - n:    <kbd>m</kbd>     -> *vim-markdown*, Toggle math syntax.
    - n:    <kbd>h</kbd>     -> *vim-markdown*, Toc horizontal.
    - n:    <kbd>v</kbd>     -> *vim-markdown*, Toc vertical.
  - <kbd>leader-o-</kbd>     -> **Open**.
    - n:    <kbd>b</kbd>     -> Open file of buffer with system default browser.
    - n:    <kbd>e</kbd>     -> Open system file manager.
    - n:    <kbd>t</kbd>     -> Open terminal.
    - n:    <kbd>p</kbd>     -> *nvim-tree.lua*, nvim-tree toggle.
  - <kbd>leader-s-</kbd>     -> **Surrounding**.
    - nv:   <kbd>a</kbd>     -> Surrounding add.
    - n:    <kbd>c</kbd>     -> Surrounding change.
    - n:    <kbd>d</kbd>     -> Surrounding delete.
  - <kbd>leader-t-</kbd>     -> **Table mode**.
    - n:    <kbd>a</kbd>     -> *vim-table-mode*, Add formula.
    - n:    <kbd>c</kbd>     -> *vim-table-mode*, Evaluate formula.
    - n:    <kbd>f</kbd>     -> *vim-table-mode*, Re-align.
  - <kbd>leader-w-</kbd>     -> **Vimwiki**.
* **Miscellanea**
  - v:      <kbd>*</kbd>     -> Search visual selection.
  - invt:   <kbd>F2</kbd>    -> Toggle mouse status.


## Commands
- `CodeRun`   -> Run or compile the code in current buffer.
- `PDF`       -> Open pdf with the same name of the buffer file in the same directory.
- `PushAll`   -> Just push all to the remote origin.
  - `-b`      -> branch, current branch default.
  - `-m`      -> comment, the date default.
- `Time`      -> Echo date and time.
