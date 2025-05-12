<p align="center">
  <img alt="Neovim" src="https://raw.githubusercontent.com/neovim/neovim.github.io/master/logos/neovim-logo-300x87.png" height="80" />
  <p align="center">Neovim configuration with some personal hacks.</p>
</p>

---

# Installation

- Requirements
  - [**Neovim**](https://github.com/neovim/neovim)
  - [**Git**](https://github.com/git/git)
  - [**curl**](https://github.com/curl/curl)
  - [**Node.js**](https://nodejs.org) (If `general.use_coc` is `true`)
  - [**ripgrep**](https://github.com/BurntSushi/ripgrep)
  - [**fd**](https://github.com/sharkdp/fd)
  - [**lazygit**](https://github.com/jesseduffield/lazygit)

- Clone repository
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

- Start Neovim and wait for the installation to complete

# Configuration

Create file named `.nvimrc` (also can be `_nvimrc` on Windows) in
`home` or `config` directory.
It's a pure text file with json syntax. Example:

<u>/home/anthonyk213/.nvimrc</u>

``` json
{
  // General options
  "general": {
    // (boolean) Set this to `true` if internet connection is unavailable.
    "offline": false,
    // (string) Proxy
    "proxy": "http://127.0.0.1:7890",
    // (string|array) The shell that the terminal emulator to start with.
    "shell": ["powershell.exe", "-nologo"],
    // Use coc.nvim
    "use_coc": false
  },
  // Paths
  "path": {
    // (string) Home directory.
    "home": "$HOME",
    // (string) Desktop directory.
    "desktop": "$HOME/Desktop",
    // (string) Vimwiki directory.
    "vimwiki": "$HOME/vimwiki"
  },
  // TUI
  "tui": {
    // ("one"|"gruvbox"|"tokyonight") Color scheme
    "scheme": "one",
    // ("dark"|"light") TUI background theme
    "theme": "dark",
    // (string) Style of color scheme
    "style": "one",
    // (boolean) Make background transparent
    "transparent": false,
    // (boolean) Global statusline
    "global_statusline": false,
    // (string) Floating window border style
    "border": "single",
    // (boolean) Dim inactive window automatically
    "auto_dim": false
  },
  // GUI (neovim-qt, fvim, neovide, VimR)
  "gui": {
    // ("auto"|"dark"|"light") GUI background theme
    "theme": "auto",
    // (number) Window opacity
    "opacity": 0.98,
    // (boolean) Render ligatures
    "ligature": false,
    // (boolean) Use GUI popup menu
    "popup_menu": false,
    // (boolean) Use GUI tabline
    "tabline": false,
    // (boolean) Use GUI scroll bar
    "scroll_bar": false,
    // (number) Line space
    "line_space": 0.0,
    // (boolean) Cursor blink
    "cursor_blink": false,
    // (number) GUI font size
    "font_size": 13,
    // (string) See `guifont`
    "font_half": "Monospace",
    // (string) See `guifontwide`
    "font_wide": "Monospace"
  },
  // Language Server Protocol
  "lsp": {
    "clangd": false,
    "powershell_es": false,
    "rust_analyzer": false,
    "lua_ls": false,
    "vimls": false
  }
}
```

Set `.vimrc` for Vim (optional)
- Windows
  ``` ps1
  Copy-Item "$env:LOCALAPPDATA\nvim\viml\vimrc.vim" `
            -Destination "$env:HOMEPATH\_vimrc"
  ```
- GNU/Linux
  ``` sh
  cp "${XDG_DATA_HOME:-$HOME/.config}"/nvim/viml/vimrc.vim \
     "${XDG_DATA_HOME:-$HOME}"/.vimrc
  ```

# Key bindings

| Modifier                        | Key            | Mode | Description                                                       |
|---------------------------------|----------------|------|-------------------------------------------------------------------|
| <kbd>Ctrl</kbd>                 | <kbd>S</kbd>   | in   | Save current buffer to file.                                      |
| <kbd>Ctrl</kbd>                 | `direction`    | n    | Adjust window size.                                               |
| <kbd>Meta</kbd>                 | <kbd>a</kbd>   | in   | Select all text in current buffer.                                |
| <kbd>Meta</kbd>                 | <kbd>c</kbd>   | v    | Copy to system clipboard.                                         |
| <kbd>Meta</kbd>                 | <kbd>d</kbd>   | t    | Close the terminal.                                               |
| <kbd>Meta</kbd>                 | <kbd>e</kbd>   | n    | Focus to file explorer.                                           |
| <kbd>Meta</kbd>                 | <kbd>g</kbd>   | nv   | Find and replace.                                                 |
| <kbd>Meta</kbd>                 | <kbd>h</kbd>   | nv   | Goto the window left.                                             |
| <kbd>Meta</kbd>                 | <kbd>j</kbd>   | nv   | Goto the window below.                                            |
| <kbd>Meta</kbd>                 | <kbd>k</kbd>   | nv   | Goto the window above.                                            |
| <kbd>Meta</kbd>                 | <kbd>l</kbd>   | nv   | Goto the window right.                                            |
| <kbd>Meta</kbd>                 | <kbd>n</kbd>   | nv   | Move line(s) down.                                                |
| <kbd>Meta</kbd>                 | <kbd>p</kbd>   | nv   | Move line(s) up.                                                  |
| <kbd>Meta</kbd>                 | <kbd>v</kbd>   | inv  | Paste from system clipboard.                                      |
| <kbd>Meta</kbd>                 | <kbd>w</kbd>   | inv  | Switch window in turns.                                           |
| <kbd>Meta</kbd>                 | <kbd>x</kbd>   | v    | Cut to system clipboard.                                          |
| <kbd>Meta</kbd>                 | <kbd>,</kbd>   | n    | Open `nvimrc`.                                                    |
| <kbd>Meta</kbd>                 | <kbd>CR</kbd>  | i    | Begin a new line below the cursor and insert bullet.              |
| <kbd>Meta</kbd>                 | `number`       | in   | Goto tab (Number 1, 2, 3, ..., 9, 0).                             |
| <kbd>Meta</kbd>                 | <kbd>B</kbd>   | in   | Toggle Markdown **bold**.                                         |
| <kbd>Meta</kbd>                 | <kbd>I</kbd>   | in   | Toggle Markdown *italic*.                                         |
| <kbd>Meta</kbd>                 | <kbd>M</kbd>   | in   | Toggle Markdown ***bold_italic***.                                |
| <kbd>Meta</kbd>                 | <kbd>P</kbd>   | in   | Toggle Markdown `block`.                                          |
| <kbd>Meta</kbd>                 | <kbd>U</kbd>   | inv  | Markdown <u>underscore</u>.                                       |
| <kbd>Ctrl</kbd>                 | <kbd>N</kbd>   | inv  | Cursor down.                                                      |
| <kbd>Ctrl</kbd>                 | <kbd>P</kbd>   | inv  | Cursor up.                                                        |
| <kbd>Ctrl</kbd>                 | <kbd>B</kbd>   | ci   | Cursor left.                                                      |
| <kbd>Ctrl</kbd>                 | <kbd>F</kbd>   | ci   | Cursor right.                                                     |
| <kbd>Ctrl</kbd>                 | <kbd>A</kbd>   | ci   | To the first character of the screen line.                        |
| <kbd>Ctrl</kbd>                 | <kbd>E</kbd>   | ci   | To the last character of the screen line.                         |
| <kbd>Ctrl</kbd>                 | <kbd>K</kbd>   | i    | Kill text until the end of the line.                              |
| <kbd>Meta</kbd>                 | <kbd>b</kbd>   | cin  | Cursor one word left.                                             |
| <kbd>Meta</kbd>                 | <kbd>f</kbd>   | cin  | Cursor one word right.                                            |
| <kbd>Meta</kbd>                 | <kbd>d</kbd>   | i    | Kill text until the end of the word.                              |
| <kbd>Meta</kbd>                 | <kbd>x</kbd>   | in   | Command-line mode.                                                |
|                                 | <kbd>\*</kbd>  | v    | Search visual selection downward.                                 |
|                                 | <kbd>#</kbd>   | v    | Search visual selection upward.                                   |
| <kbd>Shift</kbd>                | <kbd>F5</kbd>  | n    | `CodeRun`.                                                        |
| <kbd>Ctrl</kbd><kbd>Shift</kbd> | <kbd>F5</kbd>  | n    | `CodeRun test`.                                                   |
|                                 | <kbd>F8</kbd>  | invt | Toggle mouse status.                                              |
| <kbd>leader</kbd>               | <kbd>bc</kbd>  | n    | Set cwd to current buffer directory.                              |
| <kbd>leader</kbd>               | <kbd>bd</kbd>  | n    | Delete current buffer.                                            |
| <kbd>leader</kbd>               | <kbd>bg</kbd>  | n    | Toggle background theme.                                          |
| <kbd>leader</kbd>               | <kbd>bh</kbd>  | n    | Stop the search highlighting.                                     |
| <kbd>leader</kbd>               | <kbd>bl</kbd>  | n    | List buffers.                                                     |
| <kbd>leader</kbd>               | <kbd>bn</kbd>  | n    | Goto the next buffer.                                             |
| <kbd>leader</kbd>               | <kbd>bp</kbd>  | n    | Goto the previous buffer.                                         |
| <kbd>leader</kbd>               | <kbd>cc</kbd>  | nv   | Chinese characters count.                                         |
| <kbd>leader</kbd>               | <kbd>cs</kbd>  | n    | Toggle spell check.                                               |
| <kbd>leader</kbd>               | <kbd>ev</kbd>  | n    | Evaluate viml chunk surrounded by backquote.                      |
| <kbd>leader</kbd>               | <kbd>el</kbd>  | n    | Evaluate lisp chunk (math) surrounded by backquote.               |
| <kbd>leader</kbd>               | <kbd>fb</kbd>  | n    | *fzf.vim*, buffers.                                               |
| <kbd>leader</kbd>               | <kbd>ff</kbd>  | n    | *fzf.vim*, find files.                                            |
| <kbd>leader</kbd>               | <kbd>fg</kbd>  | n    | *fzf.vim*, live grep.                                             |
| <kbd>leader</kbd>               | <kbd>gb</kbd>  | n    | *vim-fugitive*, git blame.                                        |
| <kbd>leader</kbd>               | <kbd>gd</kbd>  | n    | *vim-fugitive*, git diff.                                         |
| <kbd>leader</kbd>               | <kbd>gh</kbd>  | n    | *vim-fugitive*, git log.                                          |
| <kbd>leader</kbd>               | <kbd>gj</kbd>  | n    | *vim-signify*, next hunk.                                         |
| <kbd>leader</kbd>               | <kbd>gk</kbd>  | n    | *vim-signify*, previous hunk.                                     |
| <kbd>leader</kbd>               | <kbd>gJ</kbd>  | n    | *vim-signify*, last hunk.                                         |
| <kbd>leader</kbd>               | <kbd>gK</kbd>  | n    | *vim-signify*, first hunk.                                        |
| <kbd>leader</kbd>               | <kbd>gl</kbd>  | n    | *vim-floaterm*, open lazygit.                                     |
| <kbd>leader</kbd>               | <kbd>gs</kbd>  | n    | Show git status.                                                  |
| <kbd>leader</kbd>               | <kbd>hb</kbd>  | nv   | Search cword/selection with Baidu.                                |
| <kbd>leader</kbd>               | <kbd>hg</kbd>  | nv   | Search cword/selection with Google.                               |
| <kbd>leader</kbd>               | <kbd>hh</kbd>  | nv   | Search cword/selection with StarDict (requires local dictionary). |
| <kbd>leader</kbd>               | <kbd>hy</kbd>  | nv   | Search cword/selection with Youdao dictionary.                    |
| <kbd>leader</kbd>               | <kbd>kc</kbd>  | nv   | Comment current/selected line(s).                                 |
| <kbd>leader</kbd>               | <kbd>ku</kbd>  | nv   | Uncomment current/selected line(s).                               |
| <kbd>leader</kbd>               | <kbd>la</kbd>  | n    | *coc.nvim*, code action.                                          |
| <kbd>leader</kbd>               | <kbd>ld</kbd>  | n    | *coc.nvim*, goto declaration.                                     |
| <kbd>leader</kbd>               | <kbd>lf</kbd>  | n    | *coc.nvim*, goto definition.                                      |
| <kbd>leader</kbd>               | <kbd>li</kbd>  | n    | *coc.nvim*, implementation.                                       |
| <kbd>leader</kbd>               | <kbd>lm</kbd>  | n    | *coc.nvim*, format.                                               |
| <kbd>leader</kbd>               | <kbd>ln</kbd>  | n    | *coc.nvim*, rename.                                               |
| <kbd>leader</kbd>               | <kbd>lq</kbd>  | n    | *coc.nvim*, atuofix.                                              |
| <kbd>leader</kbd>               | <kbd>lr</kbd>  | n    | *coc.nvim*, references.                                           |
| <kbd>leader</kbd>               | <kbd>lt</kbd>  | n    | *coc.nvim*, type definition.                                      |
| <kbd>leader</kbd>               | <kbd>l\[</kbd> | n    | *coc.nvim*, goto previous diagnostic mark.                        |
| <kbd>leader</kbd>               | <kbd>l\]</kbd> | n    | *coc.nvim*, goto next diagnostic mark.                            |
| <kbd>leader</kbd>               | <kbd>ml</kbd>  | n    | Regenerate list bullets.                                          |
| <kbd>leader</kbd>               | <kbd>mv</kbd>  | n    | *vista.vim* toggle table of content.                              |
| <kbd>leader</kbd>               | <kbd>mt</kbd>  | n    | Toggle preview (Markdown/LaTeX)                                   |
| <kbd>leader</kbd>               | <kbd>nd</kbd>  | n    | Append the weekday after a date (yyyy-mm-dd).                     |
| <kbd>leader</kbd>               | <kbd>ns</kbd>  | n    | Insert timestamp after cursor.                                    |
| <kbd>leader</kbd>               | <kbd>ob</kbd>  | n    | Open file of buffer with system default browser.                  |
| <kbd>leader</kbd>               | <kbd>oe</kbd>  | n    | Open system file manager.                                         |
| <kbd>leader</kbd>               | <kbd>ot</kbd>  | n    | Open terminal.                                                    |
| <kbd>leader</kbd>               | <kbd>op</kbd>  | n    | Toggle file explorer.                                             |
| <kbd>leader</kbd>               | <kbd>ou</kbd>  | n    | Open path or url under the cursor.                                |
| <kbd>leader</kbd>               | <kbd>sa</kbd>  | nv   | Surrounding add.                                                  |
| <kbd>leader</kbd>               | <kbd>sc</kbd>  | n    | Surrounding change.                                               |
| <kbd>leader</kbd>               | <kbd>sd</kbd>  | n    | Surrounding delete.                                               |
| <kbd>leader</kbd>               | <kbd>ta</kbd>  | n    | *vim-table-mode* add formula.                                     |
| <kbd>leader</kbd>               | <kbd>tc</kbd>  | n    | *vim-table-mode* evaluate formula.                                |
| <kbd>leader</kbd>               | <kbd>tf</kbd>  | n    | *vim-table-mode* re-align.                                        |
| <kbd>leader</kbd>               | <kbd>vs</kbd>  | n    | Show highlight information.                                       |

> <kbd>leader</kbd> is mapped to <kbd>SPACE</kbd>.

# Commands

| Command   | Arguments                       | Description                         |
|-----------|---------------------------------|-------------------------------------|
| `CodeRun` | `build`\|`test`\|...            | Run or compile the code.            |
| `PushAll` | `-b` {branch}<br/>`-m` {commit} | Just push everything to the remote. |
| `Time`    |                                 | Print date and time.                |
