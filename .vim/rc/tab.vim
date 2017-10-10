" Vim configuration: tab behaviour

" Tab behaviour in insert mode    {{{1
" - popup menu next item OR snippet OR tab character
function! s:TabInsertMode()                                          "    {{{2
    " is completion menu open? cycle to next item
    if pumvisible()
        return "\<C-n>"
    endif
    " is there a snippet that can be expanded?
    " is there a placholder inside the snippet that can be jumped to?
    if neosnippet#expandable_or_jumpable()
        return "\<Plug>(neosnippet_expand_or_jump)"
    endif
    " if no previous option worked, just use regular tab
    return "\<Tab>"
endfunction    " }}}2
inoremap <silent><expr><Tab> <SID>TabInsertMode()

" Shift-Tab behaviour in insert mode    {{{1
" - popup menu previous item OR shift-tab character
function! s:ShiftTabInsertMode()                                     "    {{{2
    " is completion menu open? cycle to previous item
    if pumvisible()
        return "\<C-p>"
    endif
    " if no previous option worked, just use regular shift-tab
    return "\<S-Tab>"
endfunction    " }}}2
inoremap <silent><expr><S-Tab> <SID>ShiftTabInsertMode()

" Tab behaviour in normal mode    {{{1
" - find next item in quickfix or location window
function! s:TabNormalMode()                                          "    {{{2
    " is there a error to jump to in location or quickfix window?
    try | cnext  | return | catch | endtry
    try | cfirst | return | catch | endtry
    try | lnext  | return | catch | endtry
    try | lfirst | return | catch | endtry
endfunction    " }}}2
nnoremap <silent><Tab> :call <SID>TabNormalMode()<CR>

" Shift-Tab behaviour in normal mode    {{{1
" - find previous item in quickfix or location window
function! s:ShiftTabNormalMode()                                     "    {{{2
    " is there a error to jump to in location or quickfix window?
    try | cprev  | return | catch | endtry
    try | cfirst | return | catch | endtry
    try | lprev  | return | catch | endtry
    try | lfirst | return | catch | endtry
endfunction    " }}}2
nnoremap <silent><S-Tab> :call <SID>ShiftTabNormalMode()<CR>
" }}}1

" vim: set foldmethod=marker :
