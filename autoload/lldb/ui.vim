

let g:lldb#ui#default_pane = ['threads', 'breakpoints', 'backtrace', 'lldb']

let g:lldb#ui#created = 0

function! lldb#ui#init()
    call s:create_panes()
    let g:lldb#ui#created = 1
endfunction

function! lldb#ui#buf_clean(bufname)

endfunction

function! s:create_panes()
    execute 'belowright vsplit variables'
        call s:buf_options()
        let &l:statusline = "%{'variables'}"
    for pane in g:lldb#ui#default_pane
        execute 'split ' . pane
        call s:buf_options()
        let &l:statusline = "%{'" . pane . "'}"
    endfor
endfunction

function! s:buf_options()
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nofoldenable
    setlocal nobuflisted
    setlocal nospell
    setlocal nonu
    setlocal filetype=lldb
endfunction

