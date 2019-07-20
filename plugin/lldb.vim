scriptencoding utf-8

if exists('g:loaded_lldb')
    finish
endif
let g:loaded_lldb = 1

" Enable debug message: 1 -> enable, 0 -> disable
let g:lldb#debug#enable = 1

nmap <silent> <LocalLeader>br <Plug>(lldb_run)
nmap <silent> <LocalLeader>bt <Plug>(lldb_backtrace)
nmap <silent> <LocalLeader>bp <Plug>(lldb_breakpoints)
nmap <silent> <LocalLeader>bn <Plug>(lldb_next)
nmap <silent> <LocalLeader>bs <Plug>(lldb_step)
nmap <silent> <LocalLeader>bc <Plug>(lldb_continue)

" Toggle
nmap <silent> <LocalLeader>bm <Plug>(lldb_set_breakpoint)

nnoremap <silent> <Plug>(lldb_run)            :call lldb#operate#run()<CR>
nnoremap <silent> <Plug>(lldb_backtrace)      :call lldb#operate#backtrace()<CR>
nnoremap <silent> <Plug>(lldb_breakpoints)    :call lldb#operate#breakpoints()<CR>
nnoremap <silent> <Plug>(lldb_next)           :call lldb#operate#next()<CR>
nnoremap <silent> <Plug>(lldb_step)           :call lldb#operate#step()<CR>
nnoremap <silent> <Plug>(lldb_continue)       :call lldb#operate#continue()<CR>
nnoremap <silent> <Plug>(lldb_set_breakpoint) :LLSetBreakPoint<CR>


command! -nargs=+ -complete=file LLStart    call lldb#operate#start(<f-args>)
command! -nargs=1 -complete=file LLKill     call lldb#operate#kill()
command! -nargs=0                LLStop     call lldb#operate#stop()
command! -nargs=1 -complete=file LLTarget   call lldb#operate#target(<q-args>)

command! -nargs=0                LLCleanBreakPoint  call lldb#sign#clean()
command! -nargs=0                LLSetBreakPoint    call lldb#sign#bp_set(expand("%:p"), <line1>)

command! -nargs=1                LLSelectVariable   call lldb#operate#select_variables(<q-args>)

command! -nargs=0                LLAllReset         call lldb#all_reset()

call lldb#init()
