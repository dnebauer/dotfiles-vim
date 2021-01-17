" Vim configuration: html file support

function! s:HtmlSupport()
    " vim-specific omnicompletion    {{{1
    if dn#rc#isVim()
        setlocal omnifunc=htmlcomplete#CompleteTags
    endif    " }}}1
endfunction

augroup vrc_html_files
    autocmd!
    autocmd FileType html call s:HtmlSupport()
augroup END

" vim:foldmethod=marker:
