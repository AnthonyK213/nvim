# Neovim Configuration


## Requirements
* [**Neovim**](https://github.com/neovim/neovim)
* [**Git**](https://github.com/git/git)
* [**curl**](https://github.com/curl/curl)
* [**ripgrep**](https://github.com/BurntSushi/ripgrep)
  & [**fd**](https://github.com/sharkdp/fd)
* [**Node.js**](https://nodejs.org) (If `use_coc`)


## Installation
* **Clone repository**
  - Windows
    ```ps1
    git clone --depth=1 -b viml https://github.com/AnthonyK213/nvim.git `
                                "$env:LOCALAPPDATA\nvim"
    ```
  - GNU/Linux
    ```sh
    git clone --depth=1 -b viml https://github.com/AnthonyK213/nvim.git \
                                "${XDG_DATA_HOME:-$HOME/.config}"/nvim
    ```
* **Start Neovim and wait for the installation to complete**
* **Customize with json (optional)**
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
  - int: <kbd>M-e</kbd>  -> File explorer focus.
  - nv:  <kbd>M-g</kbd>  -> Find and replace.
  - inv: <kbd>M-h</kbd>  -> Jump to the window left.
  - inv: <kbd>M-j</kbd>  -> Jump to the window below.
  - inv: <kbd>M-k</kbd>  -> Jump to the window above.
  - inv: <kbd>M-l</kbd>  -> Jump to the window right.
  - nv:  <kbd>M-n</kbd>  -> Move line(s) down.
  - nv:  <kbd>M-p</kbd>  -> Move line(s) up.
  - inv: <kbd>M-v</kbd>  -> Paste from system clipboard.
  - inv: <kbd>M-w</kbd>  -> Jump to the window in turn.
  - v:   <kbd>M-x</kbd>  -> Cut to system clipboard.
  - n:   <kbd>M-,</kbd>  -> Open `opt.json`.
  - i:   <kbd>M-CR</kbd> -> Auto insert bullet.
  - in:  <kbd>M-Nr</kbd> -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
  - inv: <kbd>M-B</kbd>  -> Markdown bold: **bold** 
  - inv: <kbd>M-I</kbd>  -> Markdown italic: *italic*
  - inv: <kbd>M-M</kbd>  -> Markdown bold_italic: ***bold_italic***
  - inv: <kbd>M-P</kbd>  -> Markdown block: `block`
  - inv: <kbd>M-U</kbd>  -> Markdown/HTML underscore: <u>bold</u>
* **Emacs shit**
  - inv: <kbd>C-N</kbd>  -> Emacs next line.
  - inv: <kbd>C-P</kbd>  -> Emacs previous line.
  - ci:  <kbd>C-F</kbd>  -> Emacs forward.
  - ci:  <kbd>C-B</kbd>  -> Emacs backward.
  - ci:  <kbd>C-A</kbd>  -> Emacs line start.
  - ci:  <kbd>C-E</kbd>  -> Emacs line end.
  - i:   <kbd>C-K</kbd>  -> Emacs kill test on the right.
  - cin: <kbd>M-f</kbd>  -> Emacs next word.
  - cin: <kbd>M-b</kbd>  -> Emacs last word.
  - i:   <kbd>M-d</kbd>  -> Emacs delete word.
  - in:  <kbd>M-x</kbd>  -> Command line.
* **Leader**
  > <kbd>leader</kbd> is mapped to <kbd>SPACE</kbd>.
  - <kbd>leader-b-</kbd> -> **Buffer**.
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
  - <kbd>leader-d-</kbd> -> **Date**.
    - n:    <kbd>s</kbd> -> Insert time stamp at the end of line.
    - n:    <kbd>d</kbd> -> Append day of week to yyyy-mm-dd.
  - <kbd>leader-e-</kbd> -> **Evaluate**
    - n:    <kbd>v</kbd> -> Evaluate viml chunk surrounded by backquote.
    - n:    <kbd>l</kbd> -> Evaluate lisp chunk(math) surrounded by backquote.
  - <kbd>leader-f-</kbd> -> **Find**.
    - n:    <kbd>b</kbd> -> *fzf.vim*, switch buffer.
    - n:    <kbd>f</kbd> -> *fzf.vim*, fzf  (:Files)
    - n:    <kbd>g</kbd> -> *fzf.vim*, ripgrep (:Rg)
  - <kbd>leader-g-</kbd> -> **VCS**.
    - n:    <kbd>j</kbd> -> *vim-signify*, Next hunk.
    - n:    <kbd>k</kbd> -> *vim-signify*, Previous hunk.
    - n:    <kbd>J</kbd> -> *vim-signify*, Last hunk.
    - n:    <kbd>K</kbd> -> *vim-signify*, First hunk.
    - n:    <kbd>s</kbd> -> Git status.
  - <kbd>leader-h-</kbd> -> **Search text in web browser**.
    - nv:   <kbd>b</kbd> -> Baidu
    - nv:   <kbd>g</kbd> -> Google
    - nv:   <kbd>h</kbd> -> Github
    - nv:   <kbd>y</kbd> -> Youdao
  - <kbd>leader-k-</kbd> -> **Comment**.
    - nv:   <kbd>c</kbd> -> Comment line/block.
    - nv:   <kbd>u</kbd> -> Un-comment line/block.
  - <kbd>leader-l-</kbd> -> **LSP**.
    - n:    <kbd>a</kbd> -> *coc.nvim*, code action.
    - n:    <kbd>d</kbd> -> *coc.nvim*, declaration.
    - n:    <kbd>f</kbd> -> *coc.nvim*, definition.
    - n:    <kbd>i</kbd> -> *coc.nvim*, implementation.
    - n:    <kbd>m</kbd> -> *coc.nvim*, format selection.
    - n:    <kbd>n</kbd> -> *coc.nvim*, rename.
    - n:    <kbd>q</kbd> -> *coc.nvim*, autofix.
    - n:    <kbd>r</kbd> -> *coc.nvim*, references.
    - n:    <kbd>t</kbd> -> *coc.nvim*, type definition.
    - n:    <kbd>[</kbd> -> *coc.nvim*, previous diagnostic.
    - n:    <kbd>]</kbd> -> *coc.nvim*, next diagnostic.
  - <kbd>leader-m-</kbd> -> **Markdown**.
    - n:    <kbd>l</kbd> -> Sort number list.
    - n:    <kbd>v</kbd> -> *vista.vim*, Toc vertical.
  - <kbd>leader-o-</kbd> -> **Open**.
    - n:    <kbd>b</kbd> -> Open file of buffer with system default browser.
    - n:    <kbd>e</kbd> -> Open system file manager.
    - n:    <kbd>t</kbd> -> Open terminal.
    - n:    <kbd>p</kbd> -> File explorer toggle.
    - n:    <kbd>u</kbd> -> Open path or url under the cursor.
  - <kbd>leader-s-</kbd> -> **Surrounding**.
    - nv:   <kbd>a</kbd> -> Surrounding add.
    - n:    <kbd>c</kbd> -> Surrounding change.
    - n:    <kbd>d</kbd> -> Surrounding delete.
  - <kbd>leader-t-</kbd> -> **Table mode**
    - n:    <kbd>a</kbd> -> *vim-table-mode*, Add formula.
    - n:    <kbd>c</kbd> -> *vim-table-mode*, Evaluate formula.
    - n:    <kbd>f</kbd> -> *vim-table-mode*, Re-align.
  - <kbd>leader-w-</kbd> -> **Vimwiki**.
* **Miscellanea**
  - v:    <kbd>\*</kbd>  -> Search visual selection.
  - invt: <kbd>F2</kbd>  -> Toggle mouse status.
  - n:    <kbd>F5</kbd>  -> `CodeRun`


## Commands
- `CodeRun`     -> Run or compile the code.
- `Pdf`         -> View pdf after compiling a tex file.
- `PushAll`     -> Just push everything to the remote origin.
  - `-b`        -> branch  (default: current branch).
  - `-m`        -> comment (default: date).
- `SshConfig`   -> Open and edit ~/.ssh/config
- `Time`        -> Print date and time.


## Packages
* Package manager
  - [vim-plug](https://github.com/junegunn/vim-plug)
* Display
  - [dashboard.nvim](https://github.com/glepnir/dashboard-nvim)
  - [vim-airline](https://github.com/vim-airline/vim-airline)
* Color scheme
  - [vim-one](https://github.com/rakr/vim-one)
  - [gruvbox](https://github.com/morhetz/gruvbox)
* File system
  - [vim-clap](https://github.com/liuchengxu/vim-clap)
* VCS
  - [vim-fugitive](https://github.com/tpope/vim-fugitive)
  - [vim-signify](https://github.com/mhinz/vim-signify)
* Utilities
  - [vim-speeddating](https://github.com/tpope/vim-speeddating)
  - [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)
  - [indentLine](https://github.com/Yggdroot/indentLine)
  - [vim-ipairs](https://github.com/AnthonyK213/vim-ipairs)
  - [vim-matchup](https://github.com/andymass/vim-matchup)
  - [vsession](https://github.com/skanehira/vsession)
* File type support
  - [VimTeX](https://github.com/lervag/vimtex)
  - [vimwiki](https://github.com/vimwiki/vimwiki)
  - [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
  - [presenting.vim](https://github.com/sotte/presenting.vim)
  - [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim)
* Completion; Snippet (Provide by pure vim script)
  - [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)
  - [asyncomplete-buffer.vim](https://github.com/prabirshrestha/asyncomplete-buffer.vim)
  - [vim-vsnip](https://github.com/hrsh7th/vim-vsnip)
  - [vim-vsnip-integ](https://github.com/hrsh7th/vim-vsnip-integ)
  - [nerdtree](https://github.com/preservim/nerdtree)
  - [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)
* Completion; Snippet; LSP (Provide by coc.nvim)
  - [coc.nvim](https://github.com/neoclide/coc.nvim)
  - [vista.vim](https://github.com/liuchengxu/vista.vim)
