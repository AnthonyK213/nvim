<p align="center">
  <img alt="Neovim" src="https://raw.githubusercontent.com/neovim/neovim.github.io/master/logos/neovim-logo-300x87.png" height="80" />
  <p align="center">Neovim configuration with some personal hacks.</p>
</p>

---

# Installation

- Requirements
  - [**Neovim**](https://github.com/neovim/neovim) 0.11+
  - [**Git**](https://github.com/git/git)
  - [**ripgrep**](https://github.com/BurntSushi/ripgrep) (optional)
  - [**fd**](https://github.com/sharkdp/fd) (optional)

- Clone repository
  - Windows
    ``` ps1
    git clone --depth=1 https://github.com/AnthonyK213/nvim.git `
                        "$env:LOCALAPPDATA\nvim"
    ```
  - GNU/Linux
    ``` sh
    git clone --depth=1 https://github.com/AnthonyK213/nvim.git \
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
    // (boolean) Enable nvim-upgrade. It's useful when you are using official
    // released binary archives directly rather than installers or package
    // managers.
    "upgrade": false
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
  // Terminal UI
  "tui": {
    // ("onedark"|"tokyonight"|"gruvbox"|"nightfox"|"onenord") Color scheme
    "scheme": "nightfox",
    // ("dark"|"light") Tui background theme
    "theme": "dark",
    // (string) Style of color scheme
    "style": "nord",
    // (boolean) Make background transparent
    "transparent": false,
    // (boolean) Global statusline
    "global_statusline": false,
    // (string) Floating window border style
    "border": "single",
    // (boolean) nvim-cmp ghost text
    "cmp_ghost": false,
    // (boolean) Dim inactive window automatically
    "auto_dim": false,
    // (boolean) Animation effects
    "animation": false,
    // (boolean) Show current context by indent line
    "show_context": false,
    // (boolean) Enable devicons
    "devicons": false,
    // (string|array) Welcome page title
    "welcome_header": "NEOVIM",
    // (string|array) Bufferline style
    "bufferline_style": "thin"
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
    // (boolean|object) https://github.com/clangd/clangd
    "clangd": false,
    // (boolean|object) https://github.com/LuaLS/lua-language-server
    "lua_ls": {
      "load": false,
      "settings": {
        "Lua": {
          "runtime": {
            "version": "LuaJIT"
          },
          "diagnostics": {
            "globals": [ "vim" ]
          },
          "workspace": {
            "library": {},
            "checkThirdParty": false
          },
          "telemetry": {
            "enable": false
          },
          "format": {
            "defaultConfig": {
              "indent_style": "space",
              "indent_size": "2"
            }
          }
        }
      }
    },
    // (boolean|object) https://github.com/OmniSharp/omnisharp-roslyn
    "omnisharp": {
      "load": false,
      // Some LSPs' semantic tokens are not usable
      "disable_semantic_tokens": true
    },
    // (boolean|object) https://github.com/microsoft/pyright
    "pyright": {
      "load": false,
      // Extra settings, depends on the LSP
      "settings": {
        "python": {
          "analysis": {
            "autoSearchPaths": true,
            "diagnosticMode": "workspace",
            "useLibraryCodeForTypes": true,
            "stubPath": "stubPath",
            "typeCheckingMode": "off"
          }
        }
      }
    },
    // (boolean|object) https://github.com/rust-analyzer/rust-analyzer
    "rust_analyzer": false,
    // (boolean|object) https://github.com/iamcco/vim-language-server
    "vimls": false
    // And so on...
  },
  // Treesitter
  "ts": {
    // (array) Parsers to install automatically
    "ensure_installed": [],
    // (array) File type to disable treesitter highlight
    "highlight_disable": [],
    // (array) File type to disable vim-matchup
    "matchup_disable": []
  },
  // Debug Adapter Protocol
  "dap": {
    // (boolean) https://github.com/llvm/llvm-project
    "lldb": false,
    // (boolean) https://github.com/Samsung/netcoredbg
    "netcoredbg": false,
    // (boolean) https://github.com/microsoft/debugpy
    "debugpy": false
  },
  // Disabled built-in plugins
  "disable": [
    "matchit",
    "matchparen",
    "netrwPlugin"
  ]
}
```

> After setting `lsp` in this configuration, the LSP servers can be installed
> automatically by running `Mason` command (unavailable when `general.offline`
> is `true`).

> Set `.vimrc` for Vim (optional)
> - Windows
>   ``` ps1
>   Copy-Item "$env:LOCALAPPDATA\nvim\viml\vimrc.vim" `
>             -Destination "$env:HOMEPATH\_vimrc"
>   ```
> - GNU/Linux
>   ``` sh
>   cp "${XDG_DATA_HOME:-$HOME/.config}"/nvim/viml/vimrc.vim \
>      "${XDG_DATA_HOME:-$HOME}"/.vimrc
>   ```

<!--
> Configure mailboxes (optional)
> - In `home` or `config` directory, named `.mail.json`
>   (also can be `_mail.json` on Windows)
> - Example
>   ``` json
>   {
>     "archive": "/path/to/email/archive/directory/",
>     "providers": [
>       {
>         "label": "A unique label for the mailbox provider",
>         "smtp": "SMTP server address",
>         "imap": "IMAP server address",
>         "port": 993,
>         "user_name": "User name",
>         "password": "Password"
>       }
>     ]
>   }
>   ```
-->

# Key Bindings

| Modifier                        | Key            | Mode | Description                                                       |
|---------------------------------|----------------|------|-------------------------------------------------------------------|
| <kbd>Ctrl</kbd>                 | <kbd>S</kbd>   | in   | Save current buffer to file.                                      |
| <kbd>Ctrl</kbd>                 | `direction`    | n    | Adjust window size.                                               |
| <kbd>Meta</kbd>                 | <kbd>a</kbd>   | in   | Select all text in current buffer.                                |
| <kbd>Meta</kbd>                 | <kbd>c</kbd>   | v    | Copy to system clipboard.                                         |
| <kbd>Meta</kbd>                 | <kbd>d</kbd>   | t    | Close the terminal.                                               |
| <kbd>Meta</kbd>                 | <kbd>e</kbd>   | n    | *nvim-tree.lua* find file.                                        |
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
| <kbd>Meta</kbd>                 | <kbd>B</kbd>   | in   | Toggle Markdown/LaTeX **bold**.                                   |
| <kbd>Meta</kbd>                 | <kbd>I</kbd>   | in   | Toggle Markdown/LaTeX *italic*.                                   |
| <kbd>Meta</kbd>                 | <kbd>M</kbd>   | in   | Toggle Markdown ***bold_italic***; LaTeX Roman Family.            |
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
|                                 | <kbd>F5</kbd>  | n    | *nvim-dap* continue debugging; *presenting.nvim* presenting view. |
| <kbd>Shift</kbd>                | <kbd>F5</kbd>  | n    | `CodeRun`.                                                        |
| <kbd>Ctrl</kbd><kbd>Shift</kbd> | <kbd>F5</kbd>  | n    | `CodeRun test`.                                                   |
|                                 | <kbd>F8</kbd>  | invt | Toggle mouse status.                                              |
|                                 | <kbd>F10</kbd> | n    | *nvim-dap* step over.                                             |
| <kbd>Shift</kbd>                | <kbd>F11</kbd> | n    | *nvim-dap* step into.                                             |
| <kbd>Ctrl</kbd><kbd>Shift</kbd> | <kbd>F11</kbd> | n    | *nvim-dap* step out.                                              |
| <kbd>leader</kbd>               | <kbd>bb</kbd>  | n    | *bufferline.nvim* pick buffer.                                    |
| <kbd>leader</kbd>               | <kbd>bc</kbd>  | n    | Set cwd to current buffer directory.                              |
| <kbd>leader</kbd>               | <kbd>bd</kbd>  | n    | Delete current buffer.                                            |
| <kbd>leader</kbd>               | <kbd>bg</kbd>  | n    | Toggle background theme.                                          |
| <kbd>leader</kbd>               | <kbd>bh</kbd>  | n    | Stop the search highlighting.                                     |
| <kbd>leader</kbd>               | <kbd>bn</kbd>  | n    | Goto the next buffer.                                             |
| <kbd>leader</kbd>               | <kbd>bp</kbd>  | n    | Goto the previous buffer.                                         |
| <kbd>leader</kbd>               | <kbd>cc</kbd>  | nv   | Chinese characters count.                                         |
| <kbd>leader</kbd>               | <kbd>cs</kbd>  | n    | Toggle spell check.                                               |
| <kbd>leader</kbd>               | <kbd>db</kbd>  | n    | *nvim-dap* toggle break point.                                    |
| <kbd>leader</kbd>               | <kbd>dc</kbd>  | n    | *nvim-dap* clear break point.                                     |
| <kbd>leader</kbd>               | <kbd>dl</kbd>  | n    | *nvim-dap* run last.                                              |
| <kbd>leader</kbd>               | <kbd>dn</kbd>  | n    | *nvim-dap-ui* toggle dap-ui.                                      |
| <kbd>leader</kbd>               | <kbd>dr</kbd>  | n    | *nvim-dap* toggle REPL window.                                    |
| <kbd>leader</kbd>               | <kbd>dt</kbd>  | n    | *nvim-dap* terminate.                                             |
| <kbd>leader</kbd>               | <kbd>ev</kbd>  | n    | Evaluate lua chunk surrounded by backquote.                       |
| <kbd>leader</kbd>               | <kbd>el</kbd>  | n    | Evaluate lisp chunk (math) surrounded by backquote.               |
| <kbd>leader</kbd>               | <kbd>fb</kbd>  | n    | *telescope.nvim* buffers.                                         |
| <kbd>leader</kbd>               | <kbd>ff</kbd>  | n    | *telescope.nvim* find files.                                      |
| <kbd>leader</kbd>               | <kbd>fg</kbd>  | n    | *telescope.nvim* live grep.                                       |
| <kbd>leader</kbd>               | <kbd>gb</kbd>  | n    | *gitsigns.nvim* blame line.                                       |
| <kbd>leader</kbd>               | <kbd>gn</kbd>  | n    | *Neogit* open.                                                    |
| <kbd>leader</kbd>               | <kbd>gh</kbd>  | n    | *diffview.nvim* open file history in tab.                         |
| <kbd>leader</kbd>               | <kbd>gj</kbd>  | n    | *gitsigns.nvim* next hunk.                                        |
| <kbd>leader</kbd>               | <kbd>gk</kbd>  | n    | *gitsigns.nvim* previous hunk.                                    |
| <kbd>leader</kbd>               | <kbd>gl</kbd>  | n    | *toggleterm.nvim* open lazygit.                                   |
| <kbd>leader</kbd>               | <kbd>gp</kbd>  | n    | *gitsigns.nvim* preview hunk.                                     |
| <kbd>leader</kbd>               | <kbd>gs</kbd>  | n    | Show git status.                                                  |
| <kbd>leader</kbd>               | <kbd>hb</kbd>  | nv   | Search cword/selection with Baidu.                                |
| <kbd>leader</kbd>               | <kbd>hd</kbd>  | nv   | Search cword/selection with DuckDuckGo.                           |
| <kbd>leader</kbd>               | <kbd>hg</kbd>  | nv   | Search cword/selection with Google.                               |
| <kbd>leader</kbd>               | <kbd>hh</kbd>  | nv   | Search cword/selection with StarDict (requires local dictionary). |
| <kbd>leader</kbd>               | <kbd>hy</kbd>  | nv   | Search cword/selection with Youdao dictionary.                    |
| <kbd>leader</kbd>               | <kbd>jm</kbd>  | n    | Toggle jieba-mode.                                                |
| <kbd>leader</kbd>               | <kbd>kc</kbd>  | nv   | Comment current/selected line(s).                                 |
| <kbd>leader</kbd>               | <kbd>ku</kbd>  | nv   | Uncomment current/selected line(s).                               |
| <kbd>leader</kbd>               | <kbd>l0</kbd>  | n    | Document symbol.                                                  |
| <kbd>leader</kbd>               | <kbd>la</kbd>  | n    | Code action.                                                      |
| <kbd>leader</kbd>               | <kbd>ld</kbd>  | n    | Goto declaration.                                                 |
| <kbd>leader</kbd>               | <kbd>lf</kbd>  | n    | Goto definition.                                                  |
| <kbd>leader</kbd>               | <kbd>lh</kbd>  | n    | Signature help.                                                   |
| <kbd>leader</kbd>               | <kbd>li</kbd>  | n    | Implementation.                                                   |
| <kbd>leader</kbd>               | <kbd>lk</kbd>  | n    | Show diagnostics in a floating window.                            |
| <kbd>leader</kbd>               | <kbd>lm</kbd>  | n    | Format.                                                           |
| <kbd>leader</kbd>               | <kbd>ln</kbd>  | n    | Rename.                                                           |
| <kbd>leader</kbd>               | <kbd>lr</kbd>  | n    | References.                                                       |
| <kbd>leader</kbd>               | <kbd>lt</kbd>  | n    | Type definition.                                                  |
| <kbd>leader</kbd>               | <kbd>lw</kbd>  | n    | Work space symbol.                                                |
| <kbd>leader</kbd>               | <kbd>l\[</kbd> | n    | Goto previous diagnostic mark.                                    |
| <kbd>leader</kbd>               | <kbd>l\]</kbd> | n    | Goto next diagnostic mark.                                        |
| <kbd>leader</kbd>               | <kbd>mf</kbd>  | n    | Fetch recently unseen mails from IMAP server.                     |
| <kbd>leader</kbd>               | <kbd>ml</kbd>  | n    | Regenerate list bullets.                                          |
| <kbd>leader</kbd>               | <kbd>mn</kbd>  | n    | Create a new mail(.eml file).                                     |
| <kbd>leader</kbd>               | <kbd>ms</kbd>  | n    | Send current buffer as an e-mail.                                 |
| <kbd>leader</kbd>               | <kbd>mv</kbd>  | n    | *aerial.nvim*/*VimTeX* toggle table of content.                   |
| <kbd>leader</kbd>               | <kbd>mt</kbd>  | n    | Toggle preview (Markdown/Marp/LaTeX/GLSL)                         |
| <kbd>leader</kbd>               | <kbd>mi</kbd>  | n    | glslViewer input.                                                 |
| <kbd>leader</kbd>               | <kbd>nd</kbd>  | n    | Append the weekday after a date (yyyy-mm-dd).                     |
| <kbd>leader</kbd>               | <kbd>ns</kbd>  | n    | Insert timestamp after cursor.                                    |
| <kbd>leader</kbd>               | <kbd>nt</kbd>  | n    | Print TODO list.                                                  |
| <kbd>leader</kbd>               | <kbd>ob</kbd>  | n    | Open file of buffer with system default browser.                  |
| <kbd>leader</kbd>               | <kbd>oe</kbd>  | n    | Open system file manager.                                         |
| <kbd>leader</kbd>               | <kbd>ot</kbd>  | n    | Open terminal.                                                    |
| <kbd>leader</kbd>               | <kbd>op</kbd>  | n    | *nvim-tree.lua* toggle.                                           |
| <kbd>leader</kbd>               | <kbd>ou</kbd>  | n    | Open path or url under the cursor.                                |
| <kbd>leader</kbd>               | <kbd>sa</kbd>  | nv   | Surrounding add.                                                  |
| <kbd>leader</kbd>               | <kbd>sc</kbd>  | n    | Surrounding change.                                               |
| <kbd>leader</kbd>               | <kbd>sd</kbd>  | n    | Surrounding delete.                                               |
| <kbd>leader</kbd>               | <kbd>ta</kbd>  | n    | *vim-table-mode* add formula.                                     |
| <kbd>leader</kbd>               | <kbd>tc</kbd>  | n    | *vim-table-mode* evaluate formula.                                |
| <kbd>leader</kbd>               | <kbd>tf</kbd>  | n    | *vim-table-mode* re-align.                                        |
| <kbd>leader</kbd>               | <kbd>vs</kbd>  | n    | Show highlight information.                                       |
| <kbd>leader</kbd>               | <kbd>zbd</kbd> | v    | Decode visual selection with base64.                              |
| <kbd>leader</kbd>               | <kbd>zbe</kbd> | v    | Encode visual selection with base64.                              |

> <kbd>leader</kbd> is mapped to <kbd>SPACE</kbd>.

# Commands

| Command       | Arguments                                         | Description                                |
|---------------|---------------------------------------------------|--------------------------------------------|
| `CodeRun`     | `build`\|`test`\|...                              | Run or compile the code.                   |
| `BuildCrates` | {crate}                                           | Build crates in `$config/rust/` directory. |
| `GlslViewer`  |                                                   | Open glslViewer.                           |
| `NvimUpgrade` | `stable`\|`nightly`                               | Upgrade neovim by channel.                 |
| `PushAll`     | `-b` {branch}<br/>`-m` {commit}<br/>`-r` {remote} | Just push everything to the remote.        |
| `Time`        |                                                   | Print date and time.                       |
