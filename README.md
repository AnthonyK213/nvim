# Neovim Configuration


## Requirements
* [**Neovim**](https://github.com/neovim/neovim) 0.7+
* [**Git**](https://github.com/git/git)
* [**ripgrep**](https://github.com/BurntSushi/ripgrep)
  & [**fd**](https://github.com/sharkdp/fd)


## Installation
* **Clone repository**
  - Windows
    ```ps1
    git clone --depth=1 https://github.com/AnthonyK213/nvim.git `
                        "$env:LOCALAPPDATA\nvim"
    ```
  - GNU/Linux
    ```sh
    git clone --depth=1 https://github.com/AnthonyK213/nvim.git \
                        "${XDG_DATA_HOME:-$HOME/.config}"/nvim
    ```
* **Start Neovim and wait for the installation to complete**
* **Customize with `opt.json` (optional, in the `config` directory)**
  ``` json
  {
    // Dependencies
    "dep": {
      "sh": "string|table", // Shell
      "cc": "string",       // C compiler
      "py3": "string",      // Python3 executable path
      "proxy": "string"     // Proxy
    },
    // Paths
    "path": {
      "home": "string",     // Home directory
      "cloud": "string",    // Cloud drive directory
      "desktop": "string",  // Desktop directory
      "bin": "string"       // Binaries directory
    },
    // Terminal UI
    "tui": {
      "scheme": "string", // Color scheme(onedark|tokyonight|gruvbox|nightfox)
      "theme": "string",  // Tui background theme(dark|light)
      "style": "string",  // Style of color scheme
      "transparent": false,        // Make background transparent
      "global_statusline": false,  // Global statusline
      "cmp_border": false          // nvim-cmp window border
    },
    // GUI (neovim-qt, fvim)
    "gui": {
      "theme": "string",     // GUI background theme
      "opacity": 0.98,       // Window opacity
      "ligature": false,     // Render ligatures
      "popup_menu": false,   // Use GUI popup menu
      "tabline": false,      // Use GUI tabline
      "line_space": 0.0,     // Line space
      "font_size": 13,       // GUI font size
      "font_half": "string", // See `guifont`
      "font_full": "string"  // See `guifontwide`
    },
    // Language Server Protocol
    "lsp": {
      "clangd": false,               // https://github.com/clangd/clangd
      "jedi-language-server": false, // https://github.com/pappasam/jedi-language-server
      "omnisharp": false,            // https://github.com/OmniSharp/omnisharp-roslyn
      "powershell_es": false,        // https://github.com/PowerShell/PowerShellEditorServices
      "pyright": false,              // https://github.com/microsoft/pyright
      "rust_analyzer": false,        // https://github.com/rust-analyzer/rust-analyzer
      "sumneko_lua": false,          // https://github.com/sumneko/lua-language-server
      "texlab": false,               // https://github.com/latex-lsp/texlab
      "vimls": false                 // https://github.com/iamcco/vim-language-server
    },
    // Treesitter
    "ts": {
      "ensure": [],        // Parsers to install automatically
      "hi_disable": []     // File type to disable treesitter highlight
    },
    // Built-in plugins
    "plug": {
      "matchit": false,    // Enable matchit.vim
      "matchparen": false  // Enable matchparen.vim
    }
  }
  ```
  > The comments have to be removed.
* **Install LSP servers via `nvim-lsp-installer`**
* **Set .vimrc for Vim (optional)**
  - Windows
    ```ps1
    Copy-Item "$env:LOCALAPPDATA\nvim\viml\vimrc.vim" `
              -Destination "$env:HOMEPATH\_vimrc"
    ```
  - GNU/Linux
    ```sh
    cp "${XDG_DATA_HOME:-$HOME/.config}"/nvim/viml/vimrc.vim \
       "${XDG_DATA_HOME:-$HOME}"/.vimrc
    ```


## Key bindings
* **Ctrl**
  - in:  <kbd>C-S</kbd>  -> Save.
  - n:   <kbd>C-Dt</kbd> -> Adjust window size.
* **Meta**
  - in:  <kbd>M-a</kbd>  -> Select all.
  - v:   <kbd>M-c</kbd>  -> Copy to system clipboard.
  - t:   <kbd>M-d</kbd>  -> Close the terminal.
  - in:  <kbd>M-e</kbd>  -> *nvim-tree.lua*, nvim-tree find file.
  - nv:  <kbd>M-g</kbd>  -> Find and replace.
  - inv: <kbd>M-h</kbd>  -> Jump to the window left.
  - inv: <kbd>M-j</kbd>  -> Jump to the window below.
  - inv: <kbd>M-k</kbd>  -> Jump to the window above.
  - inv: <kbd>M-l</kbd>  -> Jump to the window right.
  - nv:  <kbd>M-n</kbd>  -> Move line(s) down.
  - nv:  <kbd>M-p</kbd>  -> Move line(s) up.
  - inv: <kbd>M-v</kbd>  -> Paste from system clipboard.
  - inv: <kbd>M-w</kbd>  -> Jump to the window in turns.
  - v:   <kbd>M-x</kbd>  -> Cut to system clipboard.
  - n:   <kbd>M-,</kbd>  -> Open `opt.json`.
  - i:   <kbd>M-CR</kbd> -> Auto insert bullet.
  - in:  <kbd>M-Nr</kbd> -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
  - in:  <kbd>M-B</kbd>  -> Markdown **bold**.
  - in:  <kbd>M-I</kbd>  -> Markdown *italic*.
  - in:  <kbd>M-M</kbd>  -> Markdown ***bold_italic***.
  - in:  <kbd>M-P</kbd>  -> Markdown `block`.
  - inv: <kbd>M-U</kbd>  -> Markdown/HTML <u>underscore</u>.
* **Emacs shit**
  - inv: <kbd>C-N</kbd>  -> Emacs next line.
  - inv: <kbd>C-P</kbd>  -> Emacs previous line.
  - ci:  <kbd>C-F</kbd>  -> Emacs move forward.
  - ci:  <kbd>C-B</kbd>  -> Emacs move backward.
  - ci:  <kbd>C-A</kbd>  -> Emacs line start.
  - ci:  <kbd>C-E</kbd>  -> Emacs line end.
  - i:   <kbd>C-K</kbd>  -> Emacs kill text on the right.
  - cin: <kbd>M-f</kbd>  -> Emacs next word.
  - cin: <kbd>M-b</kbd>  -> Emacs last word.
  - i:   <kbd>M-d</kbd>  -> Emacs delete word.
  - in:  <kbd>M-x</kbd>  -> Command line.
* **Leader**
  > <kbd>leader</kbd> is mapped to <kbd>SPACE</kbd>.
  - <kbd>leader-b-</kbd> -> **Buffer**.
    - n:    <kbd>b</kbd> -> *nvim-bufferline.lua*, BufferLinePick.
    - n:    <kbd>c</kbd> -> Set directory to the current buffer.
    - n:    <kbd>d</kbd> -> Delete buffer.
    - n:    <kbd>g</kbd> -> Toggle background.
    - n:    <kbd>h</kbd> -> Turn off highlights.
    - n:    <kbd>l</kbd> -> List buffers.
    - n:    <kbd>n</kbd> -> Next buffer.
    - n:    <kbd>p</kbd> -> Previous buffer.
  - <kbd>leader-c-</kbd> -> **Check**.
    - nv:   <kbd>c</kbd> -> Chinese characters count.
    - n:    <kbd>s</kbd> -> Toggle spell check status.
  - <kbd>leader-d-</kbd> -> **GTD**.
    - n:    <kbd>d</kbd> -> Append the day of week to yyyy-mm-dd.
    - n:    <kbd>s</kbd> -> Insert timestamp after cursor.
    - n:    <kbd>t</kbd> -> Print TODO list.
  - <kbd>leader-e-</kbd> -> **Evaluate**.
    - n:    <kbd>v</kbd> -> Evaluate lua chunk surrounded by backquote.
    - n:    <kbd>l</kbd> -> Evaluate lisp chunk(math) surrounded by backquote.
  - <kbd>leader-f-</kbd> -> **Find**.
    - n:    <kbd>b</kbd> -> *telescope.nvim*, buffers.
    - n:    <kbd>f</kbd> -> *telescope.nvim*, find_files.
    - n:    <kbd>g</kbd> -> *telescope.nvim*, live_grep.
  - <kbd>leader-g-</kbd> -> **VCS**.
    - n:    <kbd>b</kbd> -> *gitsigns.nvim*, blame line.
    - n:    <kbd>j</kbd> -> *gitsigns.nvim*, next hunk.
    - n:    <kbd>k</kbd> -> *gitsigns.nvim*, previous hunk.
    - n:    <kbd>p</kbd> -> *gitsigns.nvim*, preview hunk.
    - n:    <kbd>n</kbd> -> *neogit*, open neogit status window.
    - n:    <kbd>s</kbd> -> Git status.
  - <kbd>leader-h-</kbd> -> **Search text in web browser**.
    - nv:   <kbd>b</kbd> -> Baidu
    - nv:   <kbd>g</kbd> -> Google
    - nv:   <kbd>h</kbd> -> Github
    - nv:   <kbd>y</kbd> -> Youdao
  - <kbd>leader-k-</kbd> -> **Comment**.
    - nv:   <kbd>c</kbd> -> Comment line/block.
    - nv:   <kbd>u</kbd> -> Un-comment line/block.
  - <kbd>leader-l-</kbd> -> **LSP**
    - n:    <kbd>0</kbd> -> Document symbol.
    - n:    <kbd>a</kbd> -> Code action.
    - n:    <kbd>d</kbd> -> Jump to declaration.
    - n:    <kbd>f</kbd> -> Jump to definition.
    - n:    <kbd>h</kbd> -> Signature help.
    - n:    <kbd>i</kbd> -> Implementation.
    - n:    <kbd>m</kbd> -> Format.
    - n:    <kbd>n</kbd> -> Rename.
    - n:    <kbd>r</kbd> -> References.
    - n:    <kbd>t</kbd> -> Type definition.
    - n:    <kbd>w</kbd> -> Work space symbol.
    - n:    <kbd>[</kbd> -> Jump to previous diagnostic mark.
    - n:    <kbd>]</kbd> -> Jump to next diagnostic mark.
  - <kbd>leader-m-</kbd> -> **Markdown**
    - n:    <kbd>l</kbd> -> Sort number list.
    - n:    <kbd>v</kbd> -> *aerial.nvim*, Toc vertical.
    - n:    <kbd>t</kbd> -> *markdown-preview.nvim*, markdown preview toggle.
  - <kbd>leader-o-</kbd> -> **Open**.
    - n:    <kbd>b</kbd> -> Open file of buffer with system default browser.
    - n:    <kbd>e</kbd> -> Open system file manager.
    - n:    <kbd>t</kbd> -> Open terminal.
    - n:    <kbd>p</kbd> -> *nvim-tree.lua*, nvim-tree toggle.
    - n:    <kbd>u</kbd> -> Open path or url under the cursor.
  - <kbd>leader-s-</kbd> -> **Surrounding**.
    - nv:   <kbd>a</kbd> -> Surrounding add.
    - n:    <kbd>c</kbd> -> Surrounding change.
    - n:    <kbd>d</kbd> -> Surrounding delete.
  - <kbd>leader-t-</kbd> -> **Table mode**.
    - n:    <kbd>a</kbd> -> *vim-table-mode*, Add formula.
    - n:    <kbd>c</kbd> -> *vim-table-mode*, Evaluate formula.
    - n:    <kbd>f</kbd> -> *vim-table-mode*, Re-align.
  - <kbd>leader-v-</kbd> -> **Visual**
    - n:    <kbd>s</kbd> -> Show highlight information.
  - <kbd>leader-w-</kbd> -> **Vimwiki**.
* **Miscellanea**
  - v:   <kbd>\*/#</kbd> -> Search for the visual selection.
  - invt:<kbd>F2</kbd>   -> Toggle mouse status.
  - n:   <kbd>F5</kbd>   -> `CodeRun`


## Commands
- `CodeRun`     -> Run or compile the code.
- `NvimUpgrade` -> Upgrade neovim by channel input.
- `Pdf`         -> View pdf after compiling a tex file.
- `PushAll`     -> Just push everything to the remote origin.
  - `-b`        -> branch  (default: current branch).
  - `-m`        -> comment (default: date).
- `SshConfig`   -> Open and edit ~/.ssh/config
- `Time`        -> Print date and time.


## Packages
* Package manager
  - [packer.nvim](https://github.com/wbthomason/packer.nvim)
* Display(Optional)
  - [alpha-nvim](https://github.com/goolord/alpha-nvim)
  - [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
  - [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
  - [nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)
* Color scheme(Optional)
  - [onedark.nvim](https://github.com/navarasu/onedark.nvim)
  - [tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
  - [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim)
  - [nightfox.nvim](https://github.com/EdenEast/nightfox.nvim)
* File system
  - [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* VCS
  - [Neogit](https://github.com/TimUntersberger/neogit)
  - [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
* Utilities
  - [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
  - [vim-speeddating](https://github.com/tpope/vim-speeddating)
  - [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)
  - [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
  - [lua-pairs](https://github.com/anthonyk213/lua-pairs)
  - [vim-matchup](https://github.com/andymass/vim-matchup)
  - [neovim-session-manager](https://github.com/Shatur/neovim-session-manager)
  - [dressing.nvim](https://github.com/stevearc/dressing.nvim)
* File type support
  - [VimTeX](https://github.com/lervag/vimtex)
  - [vimwiki](https://github.com/vimwiki/vimwiki)
  - [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
  - [presenting.vim](https://github.com/sotte/presenting.vim)
  - [editorconfig.nvim](https://github.com/gpanders/editorconfig.nvim)
* Completion; Snippet; LSP; TreeSitter
  - [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
  - [vim-vsnip](https://github.com/hrsh7th/vim-vsnip)
  - [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
  - [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer)
  - [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
  - [aerial.nvim](https://github.com/stevearc/aerial.nvim)
* Games
  - [nvim-tetris](https://github.com/alec-gibson/nvim-tetris)
  - [gnugo.vim](https://github.com/AndrewRadev/gnugo.vim)
