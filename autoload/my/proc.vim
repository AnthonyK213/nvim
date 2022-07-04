let s:Process = {}

function! s:on_event(proc, job_id, data, event) abort
  if a:event ==# 'stdout'
    let a:proc["standard_output"] += a:data
  elseif a:event ==# 'stderr'
    let a:proc["standard_error"] += a:data
  endif
endfunction

function! s:on_exit_cb(proc, job_id, data, event) abort
  let a:proc.has_exited = 1
  if a:proc.on_exit != v:null
    call a:proc.on_exit(a:proc, a:job_id, a:data, a:event)
  endif
  for l:i in range(len(a:proc.extra_cb))
    call a:proc.extra_cb[l:i](a:proc, a:job_id, a:data, a:event)
  endfor
endfunction

function! s:continue_cb(proc, job_id, data, event, process) abort
  if a:data == 0
    call a:process.start()
  endif
endfunction

function! s:Process.start() dict
  if self.has_exited || !self.is_valid
    return
  endif
  let l:cmd = [self.path]
  if has_key(self.option, "args") && type(self.option.args) ==# v:t_list
    call extend(l:cmd, self.option.args)
  endif
  let l:opt = {}
  call extend(l:opt, self.option)
  let l:opt.on_stdout = {job_id, data, event ->
        \ s:on_event(self, job_id, data, event)}
  let l:opt.on_stderr = {job_id, data, event ->
        \ s:on_event(self, job_id, data, event)}
  let l:opt.on_exit = {job_id, data, event ->
        \ s:on_exit_cb(self, job_id, data, event)}
  let self.id = jobstart(l:cmd, l:opt)
endfunction

function! s:Process.clone() dict
  return my#proc#new(self.path, deepcopy(self.option), self.on_exit)
endfunction

function! s:Process.append_cb(cb) dict
  call insert(self.extra_cb, a:cb)
endfunction

function! s:Process.continue_with(process) dict
  call self.append_cb({proc, job_id, data, event ->
        \ s:continue_cb(proc, job_id, data, event, a:process)})
endfunction

function! my#proc#new(path, option = {}, on_exit = v:null) abort
  let l:o = {
        \ "path": a:path,
        \ "option": a:option,
        \ "on_exit": a:on_exit,
        \ "id": -1,
        \ "has_exited": 0,
        \ "is_valid": 1,
        \ "extra_cb": [],
        \ "standard_input": [],
        \ "standard_output": [],
        \ "standard_error": [],
        \ }
  if !my#lib#executable(a:path)
    let l:o.is_valid = 0
  endif
  call extend(l:o, s:Process)
  return l:o
endfunction

function! my#proc#queue_all(proc_list) abort
  if !empty(a:proc_list)
    for l:i in range(len(a:proc_list) - 1)
      call a:proc_list[i].continue_with(a:proc_list[i + 1])
    endfor
    call a:proc_list[0].start()
  endif
endfunction
