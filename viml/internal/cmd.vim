" Run or compile.
command! -nargs=? -complete=custom,my#compat#code_run_option CodeRun :call my#comp#code_run(<q-args>)
" Git push all.
command! -nargs=* PushAll :call my#util#git_push_all(<f-args>)
" Echo time(May be useful in full screen?)
command! Time :echo strftime("%Y-%m-%d %a %T")
