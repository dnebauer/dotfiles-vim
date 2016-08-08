" Vim configuration: java file support

function! s:JavaSupport()
    " vim omnicompletion                                               {{{1
    if has('vim')
        setlocal omnifunc=javacomplete#Complete
    endif
    " nvim completion with deoplete                                    {{{1
    if has('nvim')
        if !exists('g:deoplete#omni#input_patterns')
            let g:deoplete#omni#input_patterns = {}
        endif
        let g:deoplete#omni#input_patterns.java = [
                    \ '[^. \t0-9]\.\w*',
                    \ '[^. \t0-9]\->\w*',
                    \ '[^. \t0-9]\::\w*',
                    \ '\s[A-Z][a-z]',
                    \ '^\s*@[A-Z][a-z]',
                    \ ]
    endif                                                            " }}}1
endfunction

augroup vrc_java_files
    autocmd!
    autocmd FileType java call s:JavaSupport()
augroup END

" vim: set foldmethod=marker :
