" TODO initialize global variables
"
function! lldb#init()
    nmap <silent> <LocalLeader>br <Plug>(lldb_run)
    nmap <silent> <LocalLeader>bt <Plug>(lldb_backtrace)
    nmap <silent> <LocalLeader>bp <Plug>(lldb_breakpoints)
    nmap <silent> <LocalLeader>bn <Plug>(lldb_next)
    nmap <silent> <LocalLeader>bs <Plug>(lldb_step)
    nmap <silent> <LocalLeader>bc <Plug>(lldb_continue)

    " Toggle mode
    nmap <silent> <LocalLeader>bm <Plug>(lldb_set_breakpoint)

    nnoremap <silent> <Plug>(lldb_run)            :call lldb#operate#run()<CR>
    nnoremap <silent> <Plug>(lldb_backtrace)      :call lldb#operate#backtrace()<CR>
    nnoremap <silent> <Plug>(lldb_breakpoints)    :call lldb#operate#breakpoints()<CR>
    nnoremap <silent> <Plug>(lldb_next)           :call lldb#operate#next()<CR>
    nnoremap <silent> <Plug>(lldb_step)           :call lldb#operate#step()<CR>
    nnoremap <silent> <Plug>(lldb_continue)       :call lldb#operate#continue()<CR>
    nnoremap <silent> <Plug>(lldb_set_breakpoint) :LLSetBreakPoint<CR>


    command! -nargs=1 -complete=file LLTarget   call lldb#operate#target(<q-args>)
    " command! -nargs=1 -complete=file LLStart    call lldb#operate#start(<q-args>)
    command! -nargs=1 -complete=file LLKill     call lldb#operate#kill()
    command! -nargs=0                LLStop     call lldb#operate#stop()

    command! -nargs=0                LLCleanBreakPoint  call lldb#sign#clean()
    command! -nargs=0 -range         LLSetBreakPoint    call lldb#sign#bp_set(expand("%:p"), <line1>)

    " test command
    command! -nargs=0 -complete=file LLStart    call lldb#operate#start('test')

endfunction
