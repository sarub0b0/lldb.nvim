scriptencoding utf-8
if exists('g:loaded_lldb_operate_autoload')
    finish
endif
let g:loaded_lldb_operate_autoload = 1

let g:job = {}

let g:job = s:job.new()

function! s:job.new()
    return deepcopy(s:job)
endfunction
if has('nvim')
    function! s:job.start(command, callback)
        echomsg 'nvim start'
    endfunction

    function! s:job.stop()
        echomsg 'nvim stop'
    endfunction

    function! s:job.send(cmd)
        echomsg 'nvim send'
    endfunction
else
    function! s:job.start(command, callback)
        echomsg 'vim start'
    endfunction

    function! s:job.stop()
        echomsg 'vim stop'

    endfunction

    function! s:job.send(cmd)
        echomsg 'vim send'
    endfunction
endif

function! lldb#operate#init()
    let g:lldb#operate#buftype = ''
    let g:lldb#operate#is_breakpoints = v:false
    let s:running_type = ''
    let s:job_queue = []
    let s:output_msg = []

    let s:run_args = ''

    let s:start_bufname = ''
    let s:temp_bufname = ''

    let s:set_running_target = v:false

    let s:job_type_dict = {
                \ 'start'           : 'start',
                \ 'run'             : 'run',
                \ 'stop'            : 'stop',
                \ 'frame variable'  : 'variables',
                \ 'thread list'     : 'threads',
                \ 'breakpoint list' : 'breakpoints',
                \ 'next'            : 'next',
                \ 'step'            : 'step',
                \ 'continue'        : 'continue',
                \ 'backtrace'       : 'backtrace'
                \ }

    let s:join_jobs = []

    for l:ui in g:lldb#ui#default_panes
        if l:ui ==# 'threads'
            call add(s:join_jobs, 'thread list')
        endif
        if l:ui ==# 'variables'
            call add(s:join_jobs, 'frame variable')
        endif
    endfor
endfunction

function! lldb#operate#start(...) abort
    let s:start_bufname = bufname('%')

    let l:target_list = a:000
    let l:target = l:target_list[0]
    let s:run_args = l:target_list[1:-1]

    if g:lldb#ui#created == 0
        call lldb#ui#create_panes()
        let g:lldb#ui#created = 1
    endif
    let s:job_queue = ['start']

    let l:target_path = fnamemodify(l:target,':p')

    let s:job = jobstart(['which', 'lldb'], extend({'shell': 'which'}, s:callbacks))
    let s:job = jobstart(['lldb', '--no-use-colors', l:target_path], extend({'shell': 'lldb'}, s:callbacks))
endfunction

function! lldb#operate#stop() abort
    let s:job_queue = ['stop']
    let s:temp_bufname = bufname('%')
    call lldb#sign#clean()
    call lldb#sign#zero()
    call jobstop(s:job)
endfunction

function! lldb#operate#run() abort
    if s:set_running_target == v:false
        let s:temp_bufname = bufname('%')
        let s:set_running_target = v:true
        let s:job_queue = ['run']
        if g:lldb#operate#is_breakpoints == v:true
            call extend(s:job_queue, s:join_jobs)
        endif
        let l:run_command = 'run ' . join(s:run_args, ' ')
        call lldb#operate#send(l:run_command)
    endif
    call lldb#debug#info('Set Running target ' . string(s:set_running_target))
endfunction

function! lldb#operate#send(cmd) abort
    call lldb#debug#info('Send cmd: ' . a:cmd)
    call chansend(s:job, a:cmd . "\n")
endfunction

function! lldb#operate#backtrace() abort
    let s:job_queue = ['backtrace']
    call lldb#operate#send('backtrace')
endfunction

function! lldb#operate#variables() abort
    call lldb#operate#send('frame variable')
endfunction

function! lldb#operate#select_variables(value) abort
    let s:job_queue = ['frame variable']
    call lldb#operate#send('frame variable ' . a:value)
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
        call extend(s:job_queue, s:join_jobs)
    endif
    call lldb#operate#send('next')
endfunction

function! lldb#operate#step() abort
    let s:job_queue = ['step']
    if g:lldb#operate#is_breakpoints == v:true
        call extend(s:job_queue, s:join_jobs)
    endif
    call lldb#operate#send('step')
endfunction

function! lldb#operate#continue() abort
    let s:temp_bufname = bufname('%')
    let s:job_queue = ['continue']
    if g:lldb#operate#is_breakpoints == v:true
        call extend(s:job_queue, s:join_jobs)
    endif
    call lldb#operate#send('continue')
endfunction

function! s:on_event(job_id, data, event) dict abort
    let l:str = []

    let s:running_type = s:job_type_dict[s:job_queue[0]]
    if a:event ==# 'exit' && s:running_type !=# 'start'
        call lldb#debug#info('Exit event')
        call s:output_buffer('stop', '***** exit ******')
        call lldb#sign#reset()
        return 0
    endif

    call lldb#debug#debug(string(a:data))

    let l:str = s:remove_empty(a:data)

    call extend(s:output_msg, l:str)

    if 0 < len(l:str)
        let l:ret_check =  s:check_done(s:running_type, l:str)
        if l:ret_check == 1

            if 0 < len(s:output_msg) && eval(s:output_msg[-1] =~# 'Process [0-9]* exited .*')
                call lldb#sign#reset()
                let s:set_running_target = v:false
            endif

            if s:check_buftype_lldb(s:running_type)
                call lldb#sign#check_pc(s:output_msg)
            endif

            call s:output_buffer(s:running_type, s:output_msg)

            if s:job_queue == []
                call lldb#debug#info('No job')
                return 0
            endif

            call remove(s:job_queue, 0)
            if len(s:job_queue) == 0
                call lldb#debug#info('All job done')
                call lldb#debug#info('Running target = ' . s:set_running_target)
                return 0
            endif
            call lldb#debug#info('Send ' . string(s:job_queue[0]))
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

    execute "execute bufwinnr(bufnr('" . l:buftype . "')).'wincmd w'"

    setlocal modifiable

    let l:output_msg = ''
    if l:buftype ==# 'threads'
        let l:tmp = split(a:msg[-1], ',')
        let l:output_msg = substitute(l:tmp[0], 'tid.*', '', 'g')
                    \ . substitute(l:tmp[1], '^ 0x\([0-9]\|[a-z]\)\+ ', '','g')

    elseif l:buftype ==# 'breakpoints'
        let l:tmp = []
        for l:str in a:msg
            if l:str =~# '^[0-9]\+:\ file\ =\ .*'
                let l:tmp = add(l:tmp, substitute(l:str, ',\ exact.*', '', ''))
                call lldb#debug#debug(string(l:tmp))
            endif
        endfor
        let l:output_msg = l:tmp
    else
        let l:output_msg = a:msg
    endif

    call lldb#debug#debug(string(l:output_msg))
    let l:output_msg = s:remove_command_line(l:buftype, l:output_msg)
    call append('$', l:output_msg)
    call s:post_process(l:buftype)

    let s:output_msg = []

    let l:bufname = ''
    if a:type ==# 'start'
        execute '2d'
        execute 'g/^$/d'
        let l:bufname = s:start_bufname
    else
        let l:bufname = s:temp_bufname
    endif

    setlocal nomodifiable

    call s:move_bufname(l:bufname)

endfunction

function! s:move_bufname(bufname) abort
    execute "execute bufnr(bufname('" . a:bufname . "')).'wincmd w'"
endfunction

function! s:check_buftype_lldb(type)
    return eval(
                \ a:type ==# 'start'     ||
                \ a:type ==# 'stop'      ||
                \ a:type ==# 'run'       ||
                \ a:type ==# 'continue'  ||
                \ a:type ==# 'backtrace' ||
                \ a:type ==# 'step'      ||
                \ a:type ==# 'next'
                \ )
endfunction

function! s:check_done(type, msg) abort
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
    elseif a:type ==# 'step'
        let l:ret = s:check_step_done(a:msg)
    elseif a:type ==# 'continue'
        let l:ret = s:check_continue_done(a:msg)
    endif
    call lldb#debug#debug('check done(' . l:ret . ')')

    return eval(l:ret == 1)
endfunction

function! s:post_process(buftype) abort
    call s:buffer_move(a:buftype)
    if a:buftype !=# 'lldb'
        execute '1d'
    else
        execute '%s///ge'
    endif
    execute '$'
endfunction
function!  s:remove_command_line(buftype, msg) abort
    let l:out = a:msg
    if len(a:msg) == 0
        return a:msg
    endif
    if a:buftype !=# 'lldb'
        if a:msg[0] =~# '(lldb)'
            let l:out = a:msg[1:-1]
        endif
    endif
    call lldb#debug#debug(string(l:out))
    return l:out
endfunction

function! s:check_start_done(msg) abort
    return eval(
                \ a:msg[-1] =~# 'error: unable to find .*' ||
                \ a:msg[-1] =~# 'Current executable set to .*')
endfunction

function! s:check_run_done(msg) abort
    return eval(
                \ a:msg[-1] =~# 'Target [0-9]*: (.*) stopped' ||
                \ a:msg[-1] =~# 'Process [0-9]* exited .*'
                \ )
    return 0
endfunction

function! s:check_threads_done(msg) abort
    return eval(a:msg[-1] =~# '\* thread .*')
endfunction

function! s:check_variables_done(msg) abort
    return eval(a:msg[-1] =~# '(.*) .* = .*')
endfunction

function! s:check_breakpoints_done(msg) abort
    return eval(
                \ a:msg[-1] =~# '.* where = .*' ||
                \ a:msg[-1] =~# 'No breakpoints .*' ||
                \ a:msg[-1] =~# '.*file.*'
                \ )
endfunction

function! s:check_next_done(msg) abort
    return eval(a:msg[-1] =~# 'Target [0-9]*: (.*) stopped')
endfunction

function! s:check_step_done(msg) abort
    return eval(a:msg[-1] =~# 'Target [0-9]*: (.*) stopped')
endfunction

function! s:check_continue_done(msg) abort
    if eval(
                \ a:msg[-1] =~# 'Target [0-9]*: (.*) stopped' ||
                \ a:msg[-1] =~# 'Process [0-9]* exited .*'
                \ )

        return 1
    endif
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
    setlocal modifiable
    execute '%d'
    setlocal nomodifiable
endfunction

function! s:buffer_move(buftype) abort
    execute "execute bufwinnr(bufnr('" . a:buftype . "')).'wincmd w'"
endfunction
