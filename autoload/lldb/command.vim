
let g:lldb#command#bufname = ''

function! lldb#command#start(target) abort
    let g:lldb#command#bufname = 'lldb'
    if a:target == ''
        let s:job = jobstart(['lldb'], extend({'shell': 'lldb'}, s:callbacks))
    else
        let s:job = jobstart(['lldb', a:target], extend({'shell': 'lldb'}, s:callbacks))
    endif
endfunction


function! lldb#command#stop() abort
    let g:lldb#command#bufname = 'lldb'
    call jobstop(s:job)
endfunction

function! lldb#command#send(cmd) abort
    let g:lldb#command#bufname = 'lldb'
    call chansend(s:job, a:cmd)
endfunction

function! lldb#command#target(target) abort
    let g:lldb#command#bufname = 'lldb'
    call chansend(s:job, "target create " . a:target . "\n")
endfunction

function! lldb#command#run() abort
    let g:lldb#command#bufname = 'lldb'
    call chansend(s:job, "run\n")
endfunction

function! lldb#command#backtrace() abort
    let g:lldb#command#bufname = 'backtrace'
    call s:buffer_clean(g:lldb#command#bufname)
    call chansend(s:job, "bt\n")
endfunction

function! lldb#command#frame_variables() abort
    let g:lldb#command#bufname = 'variables'
    call s:buffer_clean(g:lldb#command#bufname)
    call chansend(s:job, "fr v\n")
endfunction

function! lldb#command#breakpoints() abort
    let g:lldb#command#bufname = 'breakpoints'
    call s:buffer_clean(g:lldb#command#bufname)
    call chansend(s:job, "br list\n")
endfunction

function! lldb#command#threads() abort
    let g:lldb#command#bufname = 'threads'
    call s:buffer_clean(g:lldb#command#bufname)
    call chansend(s:job, "thread list\n")
endfunction

function! s:on_event(job_id, data, event) dict abort
    if a:event == 'stdout'
        let str = a:data
    elseif a:event == 'stderr'
        let str = a:data
    else
        let str = a:data
    endif

    if g:lldb#ui#created == 0
        call lldb#ui#init()
        let g:lldb#ui#created = 1
    endif

    if g:lldb#command#bufname != ''
        execute "execute bufwinnr(bufnr('" . g:lldb#command#bufname . "')).'wincmd w'"
        call append(line('$'), str)
        if g:lldb#command#bufname != 'lldb'
            call feedkeys("gg", "n")
            call feedkeys("dd", "n")
            execute "%g/(lldb)/d"
        endif
        call feedkeys("\<S-g>", "n")
    endif
endfunction

let s:callbacks = {
            \ 'on_stdout': function('s:on_event'),
            \ 'on_stderr': function('s:on_event'),
            \ 'on_exit': function('s:on_event')
            \ }

function! s:buffer_clean(bufname)
    execute "execute bufwinnr(bufnr('" . a:bufname . "')).'wincmd w'"
    execute "%/.*/d"
endfunction
