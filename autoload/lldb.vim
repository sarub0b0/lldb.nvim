scriptencoding utf-8
if exists('g:loaded_lldb_autoload')
    finish
endif
let g:loaded_lldb_autoload = 1

function! lldb#init() abort
    call lldb#ui#init()
    call lldb#sign#init()
    call lldb#operate#init()
endfunction
function! lldb#exit() abort
    call lldb#operate#stop()
endfunction
