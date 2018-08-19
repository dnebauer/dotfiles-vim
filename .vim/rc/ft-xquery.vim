" Vim configuration: xquery file support

function! s:XquerySupport()
    " vim omnicompletion using neocomplete    {{{1
    let g:neocomplete#sources#omni#input_patterns.xquery =
                \ '\k\|:\|\-\|&'
    let g:neocomplete#sources#omni#functions.xquery =
                \ 'xquerycomplete#CompleteXQuery'    " }}}1
endfunction

augroup vrc_xquery_files
    autocmd!
    autocmd FileType xquery call s:XquerySupport()
augroup END

" vim:foldmethod=marker:
