scriptencoding utf-8
if exists('b:current_syntax')
    finish
endif


syntax clear

" prompt highlight
syntax match lldbPrompt /^(lldb).*/
highlight default lldbPrompt cterm=bold gui=bold ctermfg=221 guifg=#fac863

" breakpoint matched
syntax match lldbBreadpoint /^->.*/
highlight default lldbBreadpoint cterm=bold,underline gui=bold,underline ctermfg=114 guifg=#99c794

let b:current_syntax = 'lldb'
