let s:Process = {}

function! my#proc#new(path, option = {}, on_exit = v:null) abort
  let l:o = {
        \ "path": a:path,
        \ "option": a:option,
        \ "on_exit": a:on_exit,
        \ "id": -1,
        \ "has_exited": 0,
        \ "extra_cb": {},
        \ "standard_input": {},
        \ "standard_output": {},
        \ "standard_error": {},
        \ }
  call extend(l:o, s:Process)
  return l:o
endfunction

function! s:Process.clone() dict
  return my#proc#new(self.path, deepcopy(self.option), self.on_exit)
endfunction

function! s:Process.on_event(job_id, data, event) abort
  if a:event == 'stdout'
    call add(self.standard_output, a:data)
  elseif a:event == 'stderr'
    call add(self.standard_error, a:data)
  endif
endfunction

function! s:Process.start() dict
  if self.has_exited
    return
  endif
  let l:cmd = [self.path]
  if has_key(self.option, "args") && type(self.option.args) == "t_list"
    call extend(l:cmd, self.option.args)
  endif
  let l:opt = {}
  call extend(l:opt, self.option)
  let l:opt["on_stdout"] = {job_id, data, event -> self.on_event(job_id, data, event)}
  let l:opt["on_stderr"] = {job_id, data, event -> self.on_event(job_id, data, event)}
  let l:opt["on_exit"] = {job_id, data, event -> self.on_exit(job_id, data, event)}
  let self.id = jobstart(l:cmd, l:opt)
endfunction

function! s:Process.append_cb(cb) dict
  call add(self.extra_cb, a:cb)
endfunction

function! s:Process.continue_with(process) abort
  function! s:cb(job_id, data, event) abort
    if a:data == 0 && a:event == "exit"
      call process.start()
    endif
  endfunction
  call self.append_cb({job_id, data, event -> function("s:cb")})
endfunction
