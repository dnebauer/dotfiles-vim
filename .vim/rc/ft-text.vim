" Vim configuration: text file support

function! s:TextSupport()
    " improve sentence text object    {{{1
    call textobj#sentence#init()
    " add system dictionary to word completions    {{{1
    setlocal complete+=k    " }}}1
endfunction

augroup vrc_text_files
    autocmd!
    autocmd FileType text call s:TextSupport()
augroup END

" vim:foldmethod=marker:
