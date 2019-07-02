function! lldb#operate#init()
    let g:lldb#operate#buftype = ''
    let g:lldb#operate#is_breakpoints = v:false
    let s:running_type = ''
    let s:job_queue = []
    let s:output_msg = []

    let s:start_bufname = ''
    let s:temp_bufname = ''

    let s:running_target = v:false

    let s:job_type_dict = {
                \ 'start'           : 'start',
                \ 'run'             : 'run',
                \ 'stop'            : 'stop',
                \ 'frame variable'  : 'variables',
                \ 'thread list'     : 'threads',
                \ 'breakpoint list' : 'breakpoints',
                \ 'next'            : 'next',
                \ 'continue'        : 'continue'
                \ }
endfunction

function! lldb#operate#start(target) abort
    let s:start_bufname = bufname('%')

    if g:lldb#ui#created == 0
        call lldb#ui#create_panes()
        let g:lldb#ui#created = 1
    endif
    let s:job_queue = ['start']

    let s:job = jobstart(['lldb', '--no-use-colors', a:target], extend({'shell': 'lldb'}, s:callbacks))
endfunction

function! lldb#operate#stop() abort
    let s:job_queue = ['stop']
    call jobstop(s:job)
endfunction

function! lldb#operate#run() abort
    if s:running_target == v:false
        let s:temp_bufname = bufname('%')
        let s:running_target = v:true
        let s:job_queue = ['run']
        if g:lldb#operate#is_breakpoints == v:true
            call extend(s:job_queue, ['frame variable', 'thread list'])
            echomsg string(s:job_queue)
        endif
        call lldb#operate#send('run')
    endif
    echomsg "Running target"
endfunction

function! lldb#operate#send(cmd) abort
    echomsg "send cmd:" . a:cmd
    call chansend(s:job, a:cmd . "\n")
endfunction

function! lldb#operate#backtrace() abort
    call lldb#operate#send('backtrace')
endfunction

function! lldb#operate#variables() abort
    call lldb#operate#send('frame variable')
endfunction

function! lldb#operate#breakpoints() abort
    let s:temp_bufname = bufname('%')
    let s:job_queue = ['breakpoint list']
    call lldb#operate#send('breakpoint list')
endfunction

function! lldb#operate#threads() abort
    call lldb#operate#send('thread list')
endfunction

function! lldb#operate#target(target) abort
    call lldb#operate#send('target create ' . a:target)
endfunction

function! lldb#operate#next() abort
    let s:job_queue = ['next']
    if g:lldb#operate#is_breakpoints == v:true
        call extend(s:job_queue, ['frame variable', 'thread list'])
        echomsg string(s:job_queue)
    endif
    call lldb#operate#send('next')
endfunction

function! lldb#operate#step() abort
    call lldb#operate#send('step')
endfunction

function! lldb#operate#continue() abort
    let s:job_queue = ['continue']
    if g:lldb#operate#is_breakpoints == v:true
        call extend(s:job_queue, ['frame variable', 'thread list'])
        echomsg string(s:job_queue)
    endif
    call lldb#operate#send('continue')
endfunction

function! s:update()
endfunction

function! s:on_event(job_id, data, event) dict abort
    let l:str = []

    let l:str = s:remove_empty(a:data)

    call extend(s:output_msg, l:str)
    " echomsg string(s:output_msg)

    if 0 < len(l:str)
        let s:running_type = s:job_type_dict[s:job_queue[0]]
        let l:ret_check =  s:check_done(s:running_type, l:str)
        if l:ret_check == 1

            if s:check_buftype_lldb(s:running_type)
                call lldb#sign#check_pc(s:output_msg)
            endif

            call s:output_buffer(s:running_type, s:output_msg)

            if s:job_queue == []
                echomsg 'no job'
                return 0
            endif

            call remove(s:job_queue, 0)
            if len(s:job_queue) == 0
                if s:running_type ==# 'run'
                    let s:running_target = v:false
                endif
                echomsg 'all job done'
                echomsg 'Running target? ' . s:running_target
                return 0
            endif
            echomsg 'send ' . string(s:job_queue[0])
            let s:running_type = s:job_type_dict[s:job_queue[0]]
            call lldb#operate#send(s:job_queue[0])
        endif
    endif
endfunction

function! s:output_buffer(type, msg) abort
    let l:buftype = a:type
    if s:check_buftype_lldb(l:buftype)
        let l:buftype = 'lldb'
    else
        call s:buffer_clean(l:buftype)
    endif

    let l:move_window = "execute bufwinnr(bufnr('" . l:buftype . "')).'wincmd w'"
    execute l:move_window

    " setlocal modifiable

    echomsg 'output_buffer ' . l:buftype
    call append('$', a:msg)
    call s:post_process(l:buftype)

    let s:output_msg = []

    " setlocal nomodifiable

    echomsg a:type
    if a:type ==# 'start'
        echomsg 'move start buffer'
        call s:move_bufname(s:start_bufname)
    else
        echomsg 'move temp buffer'
        call s:move_bufname(s:temp_bufname)
    endif

endfunction

function! s:move_bufname(bufname) abort
    execute "execute bufnr(bufname('" . a:bufname . "')).'wincmd w'"
    echomsg "execute \"execute bufnr(bufname('" . a:bufname . "')).'wincmd w'\""
endfunction

function! s:check_buftype_lldb(type)
    return eval(
                \ a:type ==# 'start'    ||
                \ a:type ==# 'stop'     ||
                \ a:type ==# 'run'      ||
                \ a:type ==# 'continue' ||
                \ a:type ==# 'next'
                \ )
endfunction

function! s:check_done(type, msg) abort
    echomsg 'check ' . string(a:type)
    echomsg string(a:msg)
    let l:ret = 0
    if a:type ==# 'start'
        let l:ret = s:check_start_done(a:msg)
    elseif a:type ==# 'run'
        let l:ret =  s:check_run_done(a:msg)
    elseif a:type ==# 'variables'
        let l:ret =  s:check_variables_done(a:msg)
    elseif a:type ==# 'threads'
        let l:ret = s:check_threads_done(a:msg)
    elseif a:type ==# 'breakpoints'
        let l:ret = s:check_breakpoints_done(a:msg)
    elseif a:type ==# 'next'
        let l:ret = s:check_next_done(a:msg)
    elseif a:type ==# 'continue'
        let l:ret = s:check_continue_done(a:msg)
    endif
    echomsg "check done(" . l:ret . ")"

    return eval(l:ret == 1)
endfunction

function! s:post_process(buftype) abort
    call s:buffer_move(a:buftype)
    if a:buftype !=# 'lldb'
        execute 'g/(lldb)/d'
    endif
    execute 'g/^$/d'
    execute '$'
endfunction
function! s:check_start_done(msg) abort
    return eval(a:msg[-1] =~# 'error: unable to find .*' || a:msg[-1] =~# 'Current executable set to .*')
endfunction

function! s:check_run_done(msg) abort
    if g:lldb#operate#is_breakpoints == v:false
        echomsg eval(a:msg[-1] =~# 'Process [0-9]* exited .*')
        return eval(a:msg[-1] =~# 'Process [0-9]* exited .*')
    else
        echomsg eval(a:msg[-1] =~# 'Target [0-9]*: (.*) stopped')
        return eval(a:msg[-1] =~# 'Target [0-9]*: (.*) stopped')
    endif
    return 0
endfunction

function! s:check_threads_done(msg) abort
    echomsg string(a:msg)
    return eval(a:msg[-1] =~# '\* thread .*')
endfunction

function! s:check_variables_done(msg) abort
    return eval(a:msg[-1] =~# '(.*) .* = .*')
endfunction

function! s:check_breakpoints_done(msg) abort
    return eval(a:msg[-1] =~# '.* where = .*')
endfunction

function! s:check_next_done(msg) abort
    return eval(a:msg[-1] =~# 'Target [0-9]*: (.*) stopped')
endfunction

function! s:check_continue_done(msg) abort
    if eval(a:msg[-1] =~# 'Target [0-9]*: (.*) stopped') ||
                \ eval(a:msg[-1] =~# 'Process [0-9]* resuming') ||
                \ eval(a:msg[-1] =~# 'Process [0-9]* exited .*')
        return 1
    endif
    echomsg 'check continue=' . a:msg[-1]
    return 0
endfunction

let s:callbacks = {
            \ 'on_stdout': function('s:on_event'),
            \ 'on_stderr': function('s:on_event'),
            \ 'on_exit': function('s:on_event')
            \ }

function! s:remove_empty(data) abort
    if empty(a:data)
        return ['']
    endif
    let l:ret = []
    for l:v in a:data
        if l:v !=# ''
            call add(l:ret, l:v)
        endif
    endfor

    if empty(l:ret)
        return ['']
    endif
    return l:ret
endfunction

function! s:buffer_clean(buftype) abort
    call s:buffer_move(a:buftype)
    execute '%d'
endfunction

function! s:buffer_move(buftype) abort
    execute "execute bufwinnr(bufnr('" . a:buftype . "')).'wincmd w'"
endfunction
