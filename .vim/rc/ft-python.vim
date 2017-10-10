" Vim configuration: python file support

function! s:PythonSupport()
    " vim omnicompletion    {{{1
    if exists(':shell')
        setlocal omnifunc=pythoncomplete#Complete
    endif
    " nvim completion with deoplete    {{{1
    if exists(':terminal') && exists('g:loaded_deoplete')
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

" vim: set foldmethod=marker :
