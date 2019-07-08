scriptencoding utf-8
if exists('g:loaded_lldb_autoload') || !has('nvim')
    finish
endif
let g:loaded_lldb_autoload= 1

function! lldb#init()
    call lldb#ui#init()
    call lldb#sign#init()
    call lldb#operate#init()
endfunction
