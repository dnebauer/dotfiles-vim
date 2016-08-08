" Vim configuration: text file support

function! s:TextSupport()
    " add system dictionary to word completions                        {{{1
    setlocal complete+=k                                             " }}}1
endfunction

augroup vrc_text_files
    autocmd!
    autocmd FileType text call s:TextSupport()
augroup END

" vim: set foldmethod=marker :
