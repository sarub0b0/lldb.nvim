

if exists('g:loaded_lldb') || !has('nvim')
    finish
endif

let g:loaded_lldb = 1

call lldb#init()
call lldb#ui#init()
call lldb#sign#init()
call lldb#operate#init()

" let s:bp_symbol = get(g:, 'lldb#sign#bp_symbol', 'B>')
" let s:pc_symbol = get(g:, 'lldb#sign#pc_symbol', '->')

" highlight default link LLBreakpointSign Type
" highlight default link LLUnselectedPCSign NonText
" highlight default link LLUnselectedPCLine DiffChange
" highlight default link LLSelectedPCSign Debug
" highlight default link LLSelectedPCLine DiffText

" execute 'sign define llsign_bpres text=' . s:bp_symbol .
"     \ ' texthl=LLBreakpointSign linehl=LLBreakpointLine'
" execute 'sign define llsign_pcsel text=' . s:pc_symbol .
"     \ ' texthl=LLSelectedPCSign linehl=LLSelectedPCLine'
" execute 'sign define llsign_pcunsel text=' . s:pc_symbol .
"     \ ' texthl=LLUnselectedPCSign linehl=LLUnselectedPCLine'

" if get(g:, 'lldb#enable_at_startup', 0)
"     call lldb#enable()
" endif
