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
augroup END    " }}}1

" vim: set foldmethod=marker :
