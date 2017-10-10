" Vim configuration: startup

" Change to document directory    {{{1
" - function VrcCdToLocalDir()    {{{2
"   intent: cd to local directory
"   params: nil
"   return: nil
function! VrcCdToLocalDir()
    if expand('%:p') !~? '://'
        lcd %:p:h
    endif
endfunction    " }}}2
augroup vrc_local_dir
    autocmd!
    autocmd BufEnter * call VrcCdToLocalDir()
augroup END

" Remember cursor location    {{{1
" - function VrcCursorToLastPosition()    {{{2
"   intent: jump cursor to position on last exit
"   params: nil
"   return: nil
function! VrcCursorToLastPosition()
    " from ':h last-position-jump'
    if line("'\"") > 0 && line("'\"") <= line('$')
        exe "normal g`\""
    endif
endfunction    " }}}2
augroup open_cursor_pos
    autocmd!
    autocmd BufReadPost * call VrcCursorToLastPosition()
augroup END    " }}}1

" vim: set foldmethod=marker :
