# Neovim Configuration


## Requirements
* [**Neovim**](https://github.com/neovim/neovim)
* [**Python**](https://www.python.org/) (for vim-orgmode)
  > pip install pynvim  
  > pip install neovim-remote
* [**ripgrep**](https://github.com/BurntSushi/ripgrep) (for fzf.vim)
  - Crazy fast search tool.
* [**vim-plug**](https://github.com/junegunn/vim-plug)
  - Windows
    - Set plug.vim into
      > ~/AppData/Local/nvim-data/site/autoload/
  - GNU/Linux
    ```bash
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    ```


## Installation
* **Configuration Directory**
  - Windows
    > %localappdata%/nvim
  - GNU/Linux
    > ~/.config/nvim
* **Clone source code**
  ```bash
  git clone https://github.com/AnthonyK213/nvim.git -b viml
  ```
* **Set init.vim**


## Modules
- Basics
  - `basics.vim`
    - Basic configuration without any dependencies.
  - `custom.vim`
    - Global variables and key maps.
  - `deflib.vim`
    - Public function library.
- Utilities
  - `fnutil.vim`
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
- Color schemes
  - `nanovim.vim`
    - Based on [nano-emacs](https://github.com/rougier/nano-emacs)


## Key bindings
* **Ctrl**
  - n:   <kbd>C-J</kbd>      -> Indent left.
  - n:   <kbd>C-K</kbd>      -> Indent right.
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
* **Miscellanea**
  - v:      <kbd>*</kbd>     -> Search visual selection.
  - invt:   <kbd>F2</kbd>    -> Toggle mouse status.


## Commands
## Commands
- `Bib`       -> Compile with biber.
- `CodeRun`   -> Run code of current buffer.
- `OrgAgenda` -> *vim-orgmode*, Open org agenda.
- `PDF`       -> Open pdf with the same name of the buffer file in the same directory.
- `PushAll`   -> Just push all to the remote origin.
  - `-b`      -> branch, current branch default.
  - `-m`      -> comment, the date default.
- `Time`      -> Echo date and time.
- `Xe1`       -> Compile with XeLaTeX for one time.
- `Xe2`       -> Compile with XeLaTeX for two times.
