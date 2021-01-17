" Vim configuration: python file support

function! s:PythonSupport()
    " vim omnicompletion    {{{1
    if dn#rc#isVim()
        setlocal omnifunc=pythoncomplete#Complete
    endif
    " nvim completion with deoplete    {{{1
    if dn#rc#isNvim() && exists('g:loaded_deoplete')
        if !exists('g:deoplete#omni#input_patterns')
            let g:deoplete#omni#input_patterns = {}
        endif
        let g:deoplete#omni#input_patterns.python = ''
    endif    " }}}1
endfunction

augroup vrc_python_files
    autocmd!
    autocmd FileType python call s:PythonSupport()
augroup END

" vim:foldmethod=marker:
