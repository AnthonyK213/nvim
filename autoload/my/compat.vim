" Open nvimrc.
function! my#compat#open_nvimrc() abort
lua << EOF
  local exists, opt_file = require("utility.lib").get_dotfile("nvimrc")
  local cfg_dir = vim.fn.stdpath("config")
  if exists then
    require("utility.util").edit_file(opt_file, false)
    vim.api.nvim_set_current_dir(cfg_dir)
  elseif opt_file then
    vim.cmd.new(opt_file)
    local schema_uri = vim.uri_from_fname(vim.fs.joinpath(cfg_dir, "schema.json"))
    vim.api.nvim_buf_set_lines(0, 0, 1, true, {
      "{",
      string.format([[  "$schema": "%s"]], schema_uri),
      "}",
    })
  else
    vim.notify("No available configuration directory")
  end
EOF
endfunction

" Lua `require` wrapper.
function! my#compat#require(modname) abort
  call v:lua.require(a:modname)
endfunction

" Set background according to the time.
function! my#compat#bg_lock_toggle() abort
  call v:lua.require("utility.theme").bg_lock_toggle()
endfunction

" Source vim file.
function! my#compat#vim_source(file) abort
  call v:lua.require("utility.lib").vim_source(a:file)
endfunction

" VSCode Key binding.
function! my#compat#vsc_kbd(mode, lhs, cmd, block = 0) abort
  if a:mode !=# "n" && a:mode !=# "v" | return | endif
  let l:func = "require('vscode')." . (a:block ? "call" : "action")
  if a:mode ==# "n"
    let l:option = ""
    let l:prefix = "<Cmd>lua "
  elseif a:mode ==# "v"
    let l:option = ",{range={vim.api.nvim_buf_get_mark(0,'<')[1]-1,vim.api.nvim_buf_get_mark(0,'>')[1]-1}}"
    let l:prefix = ":<C-U>lua "
  else
    return
  endif
  let l:rhs = l:prefix . l:func . '(' . string(a:cmd) . l:option . ")<CR>"
  let l:opt = { "noremap": v:true, "silent": v:true }
  call nvim_set_keymap(a:mode, a:lhs, l:rhs, l:opt)
endfunction
