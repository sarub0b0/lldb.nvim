scriptencoding utf-8
if exists('g:loaded_lldb_debug_autoload')
    finish
endif
let g:loaded_lldb_debug_autoload = 1

if !exists('g:lldb#debug#enable')
    let g:lldb#debug#enable = 0
endif

function! lldb#debug#info(msg) abort
    echomsg '[INFO] ' . a:msg
endfunction

function! lldb#debug#debug(msg) abort
    if g:lldb#debug#enable == 1
        echomsg '[DEBUG] ' . a:msg
    endif
endfunction

function! lldb#debug#warn(msg) abort
    echohl WarningMsg | '[WARN] ' . a:msg | echohl None
endfunction

function! lldb#debug#err(msg) abort
    echohl ErrorMsg | '[ERR] ' . a:msg | echohl None
endfunction
