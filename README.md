# LLDB NeoVim Frontend

This plugin is created with vim script without python library. <br>
That's because recompiling LLDB does not work in MacOS.

## Usage

```
" lldb start
:LLStart <debug target> <args>

" lldb stop
:LLStop

" lldb finish. jobstop and lldb buffer delete.
:LLFinish

------------------------------------------
" Remove all breakpoints.
:LLCleanBreakPoint

" Show variable 
" ex. (lldb) frame variable argv[1]
:LLSelectVariable argv[1]
```

## Keymap
```
nmap <silent> <LocalLeader>br <Plug>(lldb_run)
nmap <silent> <LocalLeader>bt <Plug>(lldb_backtrace)
nmap <silent> <LocalLeader>bp <Plug>(lldb_breakpoints)
nmap <silent> <LocalLeader>bn <Plug>(lldb_next)
nmap <silent> <LocalLeader>bs <Plug>(lldb_step)
nmap <silent> <LocalLeader>bc <Plug>(lldb_continue)

" Toggle mode
nmap <silent> <LocalLeader>bm <Plug>(lldb_set_breakpoint)
```

## Screenshot
![screenshot](https://github.com/sarub0b0/lldb.nvim/blob/images/screenshot.jpg?raw=true)

## option
```
" Debug message: 1 -> enable, 0 -> disable
let g:lldb#debug#enable = 1

" Sign-symbol
let g:lldb#sign#bp_symbol = '>>'    " set breakpoint
let g:lldb#sign#pc_symbol = '>>'    " stop breakpoints

" Create buffer. index[0] bottom -> index[-1] top
let g:lldb#ui#default_panes = ['breakpoints', 'variables', 'lldb']
```

## Complete
- run
- breakpoints
- continue
- next
- step
- thread list
- frame variable
- stop

## TODO
- watchpoint
- backtrace
- シンボリックなパスでコンパイルされたファイルのデバッグをする時、ブレークポイントを設定できない問題
- lldb以外のバッファにsyntax highlight
