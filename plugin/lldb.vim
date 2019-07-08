scriptencoding utf-8

if exists('g:loaded_lldb') || !has('nvim')
    finish
endif
let g:loaded_lldb = 1

let s:old_cpo = &cpoptions
set cpoptions&vim

nmap <silent> <LocalLeader>br <Plug>(lldb_run)
nmap <silent> <LocalLeader>bt <Plug>(lldb_backtrace)
" nmap <silent> <LocalLeader>bp <Plug>(lldb_breakpoints)
nmap <silent> <LocalLeader>bn <Plug>(lldb_next)
nmap <silent> <LocalLeader>bs <Plug>(lldb_step)
nmap <silent> <LocalLeader>bc <Plug>(lldb_continue)

" Toggle
nmap <silent> <LocalLeader>bp <Plug>(lldb_set_breakpoint)

nnoremap <silent> <Plug>(lldb_run)            :call lldb#run_command('run')<CR>
nnoremap <silent> <Plug>(lldb_backtrace)      :call lldb#run_command('backtrace')<CR>
nnoremap <silent> <Plug>(lldb_breakpoints)    :call lldb#run_command('breakpoints')<CR>
nnoremap <silent> <Plug>(lldb_next)           :call lldb#run_command('next)<CR>
nnoremap <silent> <Plug>(lldb_step)           :call lldb#run_command('step')<CR>
nnoremap <silent> <Plug>(lldb_continue)       :call lldb#run_command('continue')<CR>


command! -nargs=1 -complete=file LLTarget   call lldb#target(<q-args>)
" TODO runで引数を取れるようにする
" command! -nargs=1 -complete=file LLstart    call lldb#operate#start(<q-args>)
command! -nargs=1 -complete=file LLKill     call lldb#kill()
command! -nargs=0                LLStop     call lldb#stop()

command! -nargs=0                LLCleanBreakPoint  call lldb#sign#clean()
command! -nargs=0 -range         LLSetBreakPoint    call lldb#sign#bp_set(expand("%:p"), <line1>)


let g:lldb#default_panes = get(g:, 'lldb#default_panes', ['breakpoints', 'variables', 'lldb'])

call lldb#init()

let &cpoptions = s:old_cpo

" TODO ブレークポイントで停止中に、配列の中身を見れるようにする
" :LLSelectVariable  -> fr v hoge[0] みたいな
" hoge[0]は引数で取れるようにする

" test command
command! -nargs=+ -complete=file LLStart    call lldb#start(<f-args>)

" nnoremap <silent> <Plug>(lldb_run)            :call lldb#operate#run()<CR>
" nnoremap <silent> <Plug>(lldb_backtrace)      :call lldb#operate#backtrace()<CR>
" nnoremap <silent> <Plug>(lldb_breakpoints)    :call lldb#operate#breakpoints()<CR>
" nnoremap <silent> <Plug>(lldb_next)           :call lldb#operate#next()<CR>
" nnoremap <silent> <Plug>(lldb_step)           :call lldb#operate#step()<CR>
" nnoremap <silent> <Plug>(lldb_continue)       :call lldb#operate#continue()<CR>
" nnoremap <silent> <Plug>(lldb_set_breakpoint) :LLSetBreakPoint<CR>


" command! -nargs=1 -complete=file LLTarget   call lldb#operate#target(<q-args>)
" " TODO runで引数を取れるようにする
" " command! -nargs=1 -complete=file LLstart    call lldb#operate#start(<q-args>)
" command! -nargs=1 -complete=file LLKill     call lldb#operate#kill()
" command! -nargs=0                LLStop     call lldb#operate#stop()

" command! -nargs=0                LLCleanBreakPoint  call lldb#sign#clean()
" command! -nargs=0 -range         LLSetBreakPoint    call lldb#sign#bp_set(expand("%:p"), <line1>)

" " TODO ブレークポイントで停止中に、配列の中身を見れるようにする
" " :LLSelectVariable  -> fr v hoge[0] みたいな
" " hoge[0]は引数で取れるようにする

" " test command
" command! -nargs=+ -complete=file LLStart    call lldb#operate#start(<f-args>)

" " call lldb#init()
" " call lldb#ui#init()
" " call lldb#sign#init()
" " call lldb#operate#init()
