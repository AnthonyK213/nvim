# Neovim Configuration


## Requirements
* [**Neovim**](https://github.com/neovim/neovim)
* [**Python**](https://www.python.org/) (for [VimTeX](https://github.com/lervag/vimtex)))
  ```sh
  pip install pynvim
  pip install neovim-remote
  ```
* [**Node.js**](https://nodejs.org) (for [coc.nvim](https://github.com/neoclide/coc.nvim))
  ```sh
  npm install neovim -g
  ```
* [**ripgrep**](https://github.com/BurntSushi/ripgrep)
  - Crazy fast search tool.
* [**vim-plug**](https://github.com/junegunn/vim-plug)
  - Windows
    ```sh
    iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
        ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
    ```
  - GNU/Linux
    ```sh
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    ```


## Installation
* **Configuration Directory**
  - Windows
    ```sh
    cd $env:LOCALAPPDATA\nvim
    ```
  - GNU/Linux
    ```sh
    cd ~/.config/nvim
    ```
* **Clone source code**
  ```sh
  git clone https://github.com/AnthonyK213/nvim.git -b viml
  ```
* **Set [init.vim](/init_expamle.vim)**


## Modules
- Basics
  - `basics.vim`
    - Basic configuration without any dependencies.
  - `custom.vim`
    - Global variables and key maps.
- Utilities
  - `fnutil.vim`
  - `subsrc.vim`
    - When don't want to use any plug-ins, this can be a simple substitute.
    - Include:
      - Netrw configuration
      - Build-in completion
      - Simple auto-pairing
- Plug-ins
  - `a_plug.vim`
    - Vim-plug load plug-ins.
  - `plugrc.vim`
    - Configurations of plug-ins.(source init_plugin at first)
  - `ps_opt.vim`      
    - Optional configurations of plugins.
- Color schemes
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
  - n:   <kbd>M-,</kbd>      -> Open `$MYVIMRC`.
  - i:   <kbd>M-CR</kbd>     -> Auto insert bullet.
  - in:  <kbd>M-Number</kbd> -> Switch tab(Number: 1, 2, 3, ..., 9, 0).
  - inv: <kbd>M-B</kbd>      -> Markdown bold: **bold** 
  - inv: <kbd>M-I</kbd>      -> Markdown italic: *italic*
  - inv: <kbd>M-M</kbd>      -> Markdown bold_italic: ***italic***
  - inv: <kbd>M-P</kbd>      -> Markdown block: `block`
  - inv: <kbd>M-U</kbd>      -> Markdown/HTML underscore: <u>bold</u>

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
    - n:    <kbd>d</kbd>     -> Append day of week to yyyy-mm-dd.
  - <kbd>leader-e-</kbd>     -> **Evaluate**
    - n:    <kbd>v</kbd>     -> Evaluate viml chunk surrounded by backquote.
  - <kbd>leader-f-</kbd>     -> **FZF**.
    - n:    <kbd>b</kbd>     -> *fzf.vim*, switch buffer using fzf.
    - n:    <kbd>f</kbd>     -> *fzf.vim*, fzf  (:Files)
    - n:    <kbd>g</kbd>     -> *fzf.vim*, ripgrep (:Rg)
  - <kbd>leader-g-</kbd>     -> **LSP**.
    - n:    <kbd>a</kbd>     -> *coc.nvim*, code action.
    - n:    <kbd>d</kbd>     -> *coc.nvim*, declaration.
    - n:    <kbd>f</kbd>     -> *coc.nvim*, definition.
    - n:    <kbd>i</kbd>     -> *coc.nvim*, implementation.
    - n:    <kbd>q</kbd>     -> *coc.nvim*, autofix.
    - n:    <kbd>r</kbd>     -> *coc.nvim*, references.
    - n:    <kbd>t</kbd>     -> *coc.nvim*, type definition.
    - n:    <kbd>[</kbd>     -> *coc.nvim*, previous diagnostic.
    - n:    <kbd>]</kbd>     -> *coc.nvim*, next diagnostic.
  - <kbd>leader-h-</kbd>     -> **VCS**.
    - n:    <kbd>j</kbd>     -> *vim-signify*, Next hunk.
    - n:    <kbd>k</kbd>     -> *vim-signify*, Previous hunk.
    - n:    <kbd>J</kbd>     -> *vim-signify*, Last hunk.
    - n:    <kbd>K</kbd>     -> *vim-signify*, First hunk.
    - n:    <kbd>h</kbd>     -> Git status.
  - <kbd>leader-k-</kbd>     -> **Search text in web browser**.
    - nv:   <kbd>b</kbd>     -> Baidu
    - nv:   <kbd>g</kbd>     -> Google
    - nv:   <kbd>h</kbd>     -> Github
    - nv:   <kbd>y</kbd>     -> Youdao
  - <kbd>leader-m-</kbd>     -> **Markdown**.
    - n:    <kbd>l</kbd>     -> Sort number list.
    - n:    <kbd>m</kbd>     -> *vim-markdown*, Toggle math syntax.
    - n:    <kbd>h</kbd>     -> *vim-markdown*, Toc horizontal.
    - n:    <kbd>v</kbd>     -> *vim-markdown*, Toc vertical.
  - <kbd>leader-o-</kbd>     -> **Open**.
    - n:    <kbd>b</kbd>     -> Open file of buffer with system default browser.
    - n:    <kbd>e</kbd>     -> Open system file manager.
    - n:    <kbd>t</kbd>     -> Open terminal.
    - nt:   <kbd>p</kbd>     -> *nerdtree*, NERDTree toggle.
  - <kbd>leader-s-</kbd>     -> **Surrounding**.
    - nv:   <kbd>a</kbd>     -> Surrounding add.
    - n:    <kbd>c</kbd>     -> Surrounding change.
    - n:    <kbd>d</kbd>     -> Surrounding delete.
  - <kbd>leader-t-</kbd>     -> **Table mode**
    - n:    <kbd>a</kbd>     -> *vim-table-mode*, Add formula.
    - n:    <kbd>c</kbd>     -> *vim-table-mode*, Evaluate formula.
    - n:    <kbd>f</kbd>     -> *vim-table-mode*, Re-align.
* **Miscellanea**
  - v:      <kbd>*</kbd>     -> Search visual selection.
  - invt:   <kbd>F2</kbd>    -> Toggle mouse status.


## Commands
- `CodeRun`   -> Run code of current buffer.
- `PDF`       -> Open pdf with the same name of the buffer file in the same directory.
- `PushAll`   -> Just push all to the remote origin.
  - `-b`      -> branch, current branch default.
  - `-m`      -> comment, the date default.
- `Time`      -> Echo date and time.
