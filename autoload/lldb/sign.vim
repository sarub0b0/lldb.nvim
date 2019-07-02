
" let s:sign_bp_name
" let s:sign_pc_sel_name
" let s:sign_pc_unsel_name
function! lldb#sign#init()

    let s:bp_symbol = get(g:, 'lldb#bp_symbol', '>>')
    let s:pc_symbol = get(g:, 'lldb#pc_symbol', '>>')

    highlight default link LLBreakpointSign Text
    highlight default link LLBreakpointLine DiffText
    highlight default link LLUnselectedPCSign NonType
    highlight default link LLUnselectedPCLine DiffChange
    highlight default link LLSelectedPCSign Debug
    highlight default link LLSelectedPCLine DiffText

    execute 'sign define llsign_bp text=' . s:bp_symbol . ' texthl=LLBreakpointSign linehl=LLBreakpointLine'
    execute 'sign define llsign_pc_sel text=' . s:pc_symbol . ' texthl=LLSelectedPCSign linehl=LLSelectedPCLine'
    execute 'sign define llsign_pc_unsel text=' . s:pc_symbol . ' texthl=LLUnselectedPCSign linehl=LLUnselectedPCLine'

endfunction

let s:bp_counter = 0
let s:bp_place_id = 1
function! lldb#sign#bp_set(file, line)
    let g:lldb#operate#buftype = 'lldb'
    execute 'sign place ' . s:bp_place_id . ' line=' . a:line . ' name=llsign_bp file=' . a:file
    let s:bp_place_id += 1
    call lldb#operate#send('breakpoint set -f ' . a:file . ' -l ' . a:line)
    call lldb#operate#breakpoints()
    let s:bp_counter += 1
    if 0 < s:bp_counter
        let g:lldb#operate#is_breakpoints = v:true
    endif
endfunction

function! lldb#sign#bp_unset(number)
    let s:bp_counter -= 1
    if s:bp_counter <= 0
        let s:bp_counter = 0
        let g:lldb#operate#is_breakpoints = v:false
    endif
endfunction

let s:pc_counter = 0
let s:pc_place_id = 1
function! lldb#sign#check_pc(msg)
    let l:param = []
    let l:param = s:pickup_param(a:msg)
    if l:param == []
        return 0
    endif
    execute 'sign place ' . s:pc_place_id . ' line=' . l:param[1] . ' name=llsign_pc_sel file=' . bufname(l:param[0])
    let s:pc_place_id += 1
endfunction

function! s:pickup_param(msg)
    for l:str in a:msg
        let l:match = matchstr(l:str, '[0-9A-Za-z_]\+\.[0-9A-Za-z_]\+:[0-9]\+')
        if l:match !=# ''
            return split(l:match, ':')
        endif
    endfor
    return []
endfunction


