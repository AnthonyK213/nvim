" Set markdown surrounding keymaps.
function! my#compat#md_kbd() abort
  let l:srd_md = { "P": "`", "I": "*", "B": "**", "M": "***", "U": "<u>" }
  for [l:key, l:val] in items(l:srd_md)
    call nvim_buf_set_keymap(0, 'n',
          \ '<M-' . l:key . '>',
          \ '<Cmd>lua require("utility.srd").srd_add("n","' . l:val . '")<CR>',
          \ { "noremap" : v:true, "silent" : v:true })
    call nvim_buf_set_keymap(0, 'v',
          \ '<M-' . l:key . '>',
          \ ':<C-U>lua require("utility.srd").srd_add("v","' . l:val . '")<CR>',
          \ { "noremap" : v:true, "silent" : v:true })
  endfor
  call nvim_buf_set_keymap(0, 'n',
        \ '<F5>',
        \ '<Cmd>PresentingStart<CR>',
        \ { "noremap" : v:true, "silent" : v:true })
  call nvim_buf_set_keymap(0, 'n',
        \ '<leader>mt',
        \ '<Cmd>MarkdownPreviewToggle<CR>',
        \ { "noremap" : v:true, "silent" : v:true })
endfunction

" Open nvimrc.
function! my#compat#open_nvimrc() abort
lua << EOF
  local exists, opt_file = require("utility.lib").get_nvimrc()
  if exists then
    require("utility.util").edit_file(opt_file, false)
    vim.api.nvim_set_current_dir(vim.fn.stdpath("config"))
  elseif opt_file then
    vim.cmd("e "..vim.fn.fnameescape(opt_file))
    vim.api.nvim_paste("{}", true, -1)
  else
    vim.notify("No available configuration directory")
  end
EOF
endfunction

" Source vim file.
function! my#compat#vim_source(file) abort
  call v:lua.require('utility.lib').vim_source(a:file)
endfunction

" Set background according to time.
function! my#compat#time_background() abort
lua << EOF
  local timer = vim.loop.new_timer()
  timer:start(0, 600, vim.schedule_wrap(function ()
    if not vim.g._my_lock_background then return end
    local hour = tonumber(os.date('%H'))
    local bg = (hour > 6 and hour < 18) and 'light' or 'dark'
    if vim.o.bg ~= bg then vim.o.bg = bg end
  end))
EOF
endfunction
