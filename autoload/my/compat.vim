" Open nvimrc.
function! my#compat#open_nvimrc() abort
lua << EOF
  local exists, opt_file = require("utility.lib").get_dotfile("nvimrc")
  if exists then
    require("utility.util").edit_file(opt_file, false)
    vim.api.nvim_set_current_dir(vim.fn.stdpath("config"))
  elseif opt_file then
    vim.cmd.new(opt_file)
    vim.api.nvim_paste("{}", true, -1)
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
  call v:lua.require("utility.util").bg_lock_toggle()
endfunction

" Source vim file.
function! my#compat#vim_source(file) abort
  call v:lua.require("utility.lib").vim_source(a:file)
endfunction

" VSCode Key binding.
function! my#compat#vsc_kbd(mode, lhs, cmd, range = [], args = v:null, block = 0) abort
  if !(a:mode ==# "n" || a:mode ==# "v") | return | endif
  let l:opts = { "noremap": v:true, "silent": v:true }
  let l:arg = a:args == v:null ? "" : "," . (type(a:args) == v:t_string ? a:args : string(a:args))
  let l:func = "VSCode"
  let l:func .= a:block ? "Call" : "Notify"
  let l:cnt = len(a:range)
  if a:mode ==# "v"
    if l:cnt == 1
      let l:func .= "Visual"
    else
      return
    endif
  elseif a:mode ==# "n"
    if l:cnt == 0
    elseif l:cnt == 3
      let l:func .= "Range"
    elseif l:cnt == 5
      let l:func .= "RangePos"
    else
      return
    endif
  endif
  let l:pos = l:cnt == 0 ? "" : "," . join(a:range, ",")
  let l:rhs = '<Cmd>call ' . l:func . '(' . string(a:cmd) . l:pos . l:arg . ")<CR>"
  call nvim_set_keymap(a:mode, a:lhs, l:rhs, l:opts)
endfunction
