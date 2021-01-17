" Vim configuration: xquery file support

function! s:XquerySupport()
    " vim omnicompletion - yet to configure    {{{1
endfunction

augroup vrc_xquery_files
    autocmd!
    autocmd FileType xquery call s:XquerySupport()
augroup END

" vim:foldmethod=marker:
