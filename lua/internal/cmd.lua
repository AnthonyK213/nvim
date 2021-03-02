-- Echo time(May be useful in full screen?)
vim.cmd('command! Time :echo strftime("%Y-%m-%d %a %T")')
-- LaTeX
vim.cmd('command! PDF lua require("utility/util").open_file(vim.fn.expand("%:r")..".pdf")')
-- Run or compile
vim.cmd('command! -nargs=? -complete=customlist,RunCompOpt CodeRun lua require("utility/util").run_or_compile(<q-args>)')
vim.api.nvim_exec(
[[
function! RunCompOpt(A,L,P)
    let l:ft = &filetype
    if l:ft == 'c'
        return ['build', 'check']
    elseif l:ft == 'rust'
        return ['build', 'clean', 'check', 'rustc']
    elseif l:ft == 'tex'
        return ['biber', 'bibtex']
    else
        return ['']
    endif
endfunction
]],
false)
-- Git push all
vim.cmd('command! -nargs=* PushAll lua require("utility/util").git_push_all(<f-args>)')
-- Scroll off
vim.cmd('augroup scroll_off')
vim.cmd('autocmd!')
vim.cmd('au BufEnter * setlocal so=5')
vim.cmd('au BufEnter *.md setlocal so=999')
vim.cmd('augroup end')
