" Vim configuration: perl6 file support

function! s:Perl6Support()
    " linting    {{{1
    " syntastic    {{{2
    " - plugin: syntastic-perl6
    if dn#rc#lintEngine() ==# 'syntastic'
        let g:syntastic_perl6_checkers             = ['perl6latest']
        let g:syntastic_enable_perl6latest_checker = 1
    endif    " }}}2
    " }}}1
endfunction

augroup vrc_perl6_files
    autocmd!
    autocmd FileType perl6 call s:Perl6Support()
augroup END

" vim: set foldmethod=marker :
