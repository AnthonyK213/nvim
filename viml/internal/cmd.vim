" Echo time(May be useful in full screen?)
command! Time :echo strftime("%Y-%m-%d %a %T")
" Open pdf file, useful when finish the compilation of tex file.
command! Pdf :call my#util#sys_open(expand("%:p:r") . ".pdf")
" Run or compile.
command! -nargs=? -complete=custom,my#compat#run_code_option CodeRun :call my#comp#run_or_compile(<q-args>)
" Git push all.
command! -nargs=* PushAll :call my#util#git_push_all(<f-args>)
" Open ssh configuration.
command! SshConfig :call my#util#edit_file("$HOME/.ssh/config", v:false)
