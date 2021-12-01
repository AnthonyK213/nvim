# Neovim Configuration


## Requirements
* [**Neovim**](https://github.com/neovim/neovim) 0.5+
* [**packer.nvim**](https://github.com/wbthomason/packer.nvim)
  - Windows
    ```sh
    git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
    ```
  - GNU/Linux
    ```sh
    git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
    ```
* [**Python**](https://www.python.org/) (For [VimTeX](https://github.com/lervag/vimtex))
  ```sh
  pip install pynvim
  pip install neovim-remote
  ```
* [**ripgrep**](https://github.com/BurntSushi/ripgrep) & [**fd**](https://github.com/sharkdp/fd) (For [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim))
  - `ripgrep` recursively searches directories for a regex pattern while respecting your gitignore.
  - `fd` is a program to find entries in your filesystem. It is a simple, fast and user-friendly alternative to `find`.
* [**jq**](https://github.com/stedolan/jq) (For [nvim-jqx](https://github.com/gennaro-tedesco/nvim-jqx))
  - Command-line JSON processor.
  > To support yaml files, [yq](https://github.com/mikefarah/yq) is needed.


## Installation
* **Clone source code and setup**
  - Windows
    ```sh
    git clone --depth=1 https://github.com/AnthonyK213/nvim.git "$env:LOCALAPPDATA\nvim"
    ```
    ```sh
    Copy-Item "$env:LOCALAPPDATA\nvim\lua\core\opt_example.lua" -Destination "$env:LOCALAPPDATA\nvim\lua\core\opt.lua"
    ```
  - GNU/Linux
    ```sh
    git clone --depth=1 https://github.com/AnthonyK213/nvim.git "${XDG_DATA_HOME:-$HOME/.config}"/nvim
    ```
    ```sh
    cp "${XDG_DATA_HOME:-$HOME/.config}"/nvim/lua/core/opt_example.lua \
       "${XDG_DATA_HOME:-$HOME/.config}"/nvim/lua/core/opt.lua
    ```
* **Install plugins**
  ```vim
  :PackerSync
  ```
* **opt.lua options (see [lua/core/opt.lua](lua/core/opt_example.lua))**
  - Essential:
    - **dep** -> Dependencies
      - `cc`  -> C compiler
      - `sh`  -> Shell
      - `py3` -> Python3 executable path
    - **path** -> Path
      - `home`    -> Home directory
      - `cloud`   -> Cloud drive directory
      - `desktop` -> Desktop directory
      - `bin`     -> Binaries directory
    - **tui** -> Tui
      - `bg`    -> Tui background
      - `theme` -> Style of color theme
  - Optional:
    - **gui** -> Gui (neovim-qt, fvim)
      - `bg`        -> Gui background
      - `font_half` -> See `guifont`
      - `font_full` -> See `guifontwide`
      - `font_size` -> Gui font size
    - **lsp** -> Language Server Protocol
      - [clangd](https://github.com/clangd/clangd)
      - [jedi_language_server](https://github.com/pappasam/jedi-language-server)
      - [powershell_es](https://github.com/PowerShell/PowerShellEditorServices)
      - [pyright](https://github.com/microsoft/pyright)
      - [omnisharp](https://github.com/OmniSharp/omnisharp-roslyn)
      - [rls](https://github.com/rust-lang/rls)
      - [rust_analyzer](https://github.com/rust-analyzer/rust-analyzer)
      - [sumneko_lua](https://github.com/sumneko/lua-language-server)
      - [texlab](https://github.com/latex-lsp/texlab)
      - [vimls](https://github.com/iamcco/vim-language-server)
    - **ts** -> Treesitter
      - `ensure`     -> Parsers to install automatically
      - `hi_disable` -> File type to disable treesitter highlight
    - **plug** -> Built-in plugins
      - `matchit`    -> matchit.vim
      - `matchparen` -> matchparen.vim
* **.vimrc(optional)**
  - Windows
    ```sh
    Copy-Item "$env:LOCALAPPDATA\nvim\viml\vimrc.vim" -Destination "$env:HOMEPATH\_vimrc"
    ```
  - GNU/Linux
    ```sh
    cp "${XDG_DATA_HOME:-$HOME/.config}"/nvim/viml/vimrc.vim "${XDG_DATA_HOME:-$HOME}"/.vimrc
    ```


## Modules
- Lua
  - `core`
    - Set up options.
  - `internal`
    - Variables; mappings; commands.
  - `packages`
    - Plugins managed by packer.nvim and configurations.
  - `utility`
    - Function library.
- Vim script
  - `basics.vim`
    - Basic vim options.
  - `subsrc.vim`
    - Make vim/neovim a little handdier with no plugins.
  - `vimrc.vim`
    - Configuration for vim.
- Snippet
  - Visual studio code standard snippets.
- Color scheme
  - `nanovim.vim`
    - Based on [nano-emacs](https://github.com/rougier/nano-emacs)


## Packages
* Package manager
  - [packer.nvim](https://github.com/wbthomason/packer.nvim)
* Display(Optional)
  - [tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
  - [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
  - [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
  - [nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)
  - [alpha-nvim](https://github.com/goolord/alpha-nvim)
* File system
  - [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* VCS
  - [Neogit](https://github.com/TimUntersberger/neogit)
  - [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
* Utilities
  - [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
  - [nvim-jqx](https://github.com/gennaro-tedesco/nvim-jqx)
  - [vim-speeddating](https://github.com/tpope/vim-speeddating)
  - [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)
  - [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
  - [lua-pairs](https://github.com/anthonyk213/lua-pairs)
  - [neovim-session-manager](https://github.com/Shatur/neovim-session-manager)
* File type support
  - [VimTeX](https://github.com/lervag/vimtex)
  - [vimwiki](https://github.com/vimwiki/vimwiki)
  - [vim-markdown](https://github.com/plasticboy/vim-markdown)
  - [vim-processing](https://github.com/sophacles/vim-processing)
  - [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
  - [presenting.vim](https://github.com/sotte/presenting.vim)
* Snippet; Completion; LSP; TreeSitter
  - [vim-vsnip](https://github.com/hrsh7th/vim-vsnip)
  - [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
  - [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
  - [aerial.nvim](https://github.com/stevearc/aerial.nvim)
  - [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
  - [nvim-gps](https://github.com/SmiteshP/nvim-gps)
  - [vim-matchup](https://github.com/andymass/vim-matchup)
* Games
  - [nvim-tetris](https://github.com/alec-gibson/nvim-tetris)


## Key bindings
* **Ctrl**
  - in:  <kbd>C-S</kbd>      -> Save.
  - n:   <kbd>C-Direct</kbd> -> Adjust window size.
* **Meta**
  - in:  <kbd>M-a</kbd>      -> Select all.
  - v:   <kbd>M-c</kbd>      -> Copy to system clipboard.
  - t:   <kbd>M-d</kbd>      -> Close the terminal.
  - int: <kbd>M-e</kbd>      -> *nvim-tree.lua*, nvim-tree find file.
  - nv:  <kbd>M-g</kbd>      -> Find and replace.
  - inv: <kbd>M-h</kbd>      -> Jump to the window left.
  - inv: <kbd>M-j</kbd>      -> Jump to the window below.
  - inv: <kbd>M-k</kbd>      -> Jump to the window above.
  - inv: <kbd>M-l</kbd>      -> Jump to the window right.
  - nv:  <kbd>M-n</kbd>      -> Normal command.
  - inv: <kbd>M-v</kbd>      -> Paste from system clipboard.
  - inv: <kbd>M-w</kbd>      -> Jump to the window in turns.
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
  - inv: <kbd>C-N</kbd>      -> Emacs next line.
  - inv: <kbd>C-P</kbd>      -> Emacs previous line.
  - ci:  <kbd>C-F</kbd>      -> Emacs move forward.
  - ci:  <kbd>C-B</kbd>      -> Emacs move backward.
  - ci:  <kbd>C-A</kbd>      -> Emacs line start.
  - ci:  <kbd>C-E</kbd>      -> Emacs line end.
  - i:   <kbd>C-K</kbd>      -> Emacs kill text on the right.
  - cin: <kbd>M-f</kbd>      -> Emacs next word.
  - cin: <kbd>M-b</kbd>      -> Emacs last word.
  - i:   <kbd>M-d</kbd>      -> Emacs delete word.
  - in:  <kbd>M-x</kbd>      -> Command line.
* **Leader**
  > <kbd>leader</kbd> is mapped to <kbd>SPACE</kbd>.
  - <kbd>leader-b-</kbd>     -> **Buffer**.
    - n:    <kbd>b</kbd>     -> *nvim-bufferline.lua*, BufferLinePick.
    - n:    <kbd>c</kbd>     -> Set directory to the current buffer.
    - n:    <kbd>d</kbd>     -> Delete buffer.
    - n:    <kbd>g</kbd>     -> Toggle background.
    - n:    <kbd>h</kbd>     -> Turn off highlights.
    - n:    <kbd>l</kbd>     -> List buffers.
    - n:    <kbd>n</kbd>     -> Next buffer.
    - n:    <kbd>p</kbd>     -> Previous buffer.
  - <kbd>leader-c-</kbd>     -> **Check**.
    - nv:   <kbd>c</kbd>     -> Chinese characters count.
    - n:    <kbd>s</kbd>     -> Toggle spell check status.
  - <kbd>leader-d-</kbd>     -> **GTD**.
    - n:    <kbd>d</kbd>     -> Append the day of week to yyyy-mm-dd.
    - n:    <kbd>s</kbd>     -> Insert timestamp after cursor.
    - n:    <kbd>t</kbd>     -> Print TODO list.
  - <kbd>leader-e-</kbd>     -> **Evaluate**.
    - n:    <kbd>v</kbd>     -> Evaluate lua chunk surrounded by backquote.
    - n:    <kbd>l</kbd>     -> Evaluate lisp chunk(math) surrounded by backquote.
  - <kbd>leader-f-</kbd>     -> **Find**.
    - n:    <kbd>b</kbd>     -> *telescope.nvim*, buffers.
    - n:    <kbd>f</kbd>     -> *telescope.nvim*, find_files.
    - n:    <kbd>g</kbd>     -> *telescope.nvim*, live_grep.
  - <kbd>leader-g-</kbd>     -> **VCS**.
    - n:    <kbd>b</kbd>     -> *gitsigns.nvim*, blame line.
    - n:    <kbd>j</kbd>     -> *gitsigns.nvim*, next hunk.
    - n:    <kbd>k</kbd>     -> *gitsigns.nvim*, previous hunk.
    - n:    <kbd>p</kbd>     -> *gitsigns.nvim*, preview hunk.
    - n:    <kbd>n</kbd>     -> *neogit*, open neogit status window.
    - n:    <kbd>s</kbd>     -> Git status.
  - <kbd>leader-h-</kbd>     -> **Search text in web browser**.
    - nv:   <kbd>b</kbd>     -> Baidu
    - nv:   <kbd>g</kbd>     -> Google
    - nv:   <kbd>h</kbd>     -> Github
    - nv:   <kbd>y</kbd>     -> Youdao
  - <kbd>leader-k-</kbd>     -> **Comment**.
    - nv:   <kbd>c</kbd>     -> Comment line/block.
    - nv:   <kbd>u</kbd>     -> Un-comment line/block.
  - <kbd>leader-l-</kbd>     -> **LSP**
    - n:    <kbd>0</kbd>     -> `vim.lsp.buf.document_symbol()`
    - n:    <kbd>a</kbd>     -> `vim.lsp.buf.code_action()`
    - n:    <kbd>d</kbd>     -> `vim.lsp.buf.declaration()`
    - n:    <kbd>f</kbd>     -> `vim.lsp.buf.definition()`
    - n:    <kbd>h</kbd>     -> `vim.lsp.buf.signature_help()`
    - n:    <kbd>i</kbd>     -> `vim.lsp.buf.implementation()`
    - n:    <kbd>m</kbd>     -> `vim.lsp.buf.formatting_sync()`
    - n:    <kbd>n</kbd>     -> `vim.lsp.buf.rename()`
    - n:    <kbd>r</kbd>     -> `vim.lsp.buf.references()`
    - n:    <kbd>t</kbd>     -> `vim.lsp.buf.type_definition()`
    - n:    <kbd>w</kbd>     -> `vim.lsp.buf.workspace_symbol()`
    - n:    <kbd>[</kbd>     -> `vim.lsp.diagnostic.goto_prev()`
    - n:    <kbd>]</kbd>     -> `vim.lsp.diagnostic.goto_next()`
  - <kbd>leader-m-</kbd>     -> **Markdown**
    - n:    <kbd>l</kbd>     -> Sort number list.
    - n:    <kbd>m</kbd>     -> *vim-markdown*, Toggle math syntax.
    - n:    <kbd>h</kbd>     -> *vim-markdown*, Toc horizontal.
    - n:    <kbd>v</kbd>     -> *vim-markdown*, Toc vertical.
    - n:    <kbd>t</kbd>     -> *markdown-preview.nvim*, markdown preview toggle.
  - <kbd>leader-o-</kbd>     -> **Open**.
    - n:    <kbd>b</kbd>     -> Open file of buffer with system default browser.
    - n:    <kbd>e</kbd>     -> Open system file manager.
    - n:    <kbd>t</kbd>     -> Open terminal.
    - n:    <kbd>p</kbd>     -> *nvim-tree.lua*, nvim-tree toggle.
    - nv:   <kbd>u</kbd>     -> Open url under the cursor or in the selection.
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
  - v:      <kbd>*</kbd>     -> Search the visual selection.
  - invt:   <kbd>F2</kbd>    -> Toggle mouse status.


## Commands
- `CodeRun`   -> Run or compile the code of current buffer.
- `CodeBuild` -> Build or make the project.
- `PDF`       -> Open pdf with the same name of the buffer file in the same directory.
- `PushAll`   -> Just push everything to the remote origin.
  - `-b`      -> branch,  default -> current branch.
  - `-m`      -> comment, default -> date.
- `SshConfig` -> Open and edit ~/.ssh/config
- `Time`      -> Echo date and time.

> vim:set wrap:
