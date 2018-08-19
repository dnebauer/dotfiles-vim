" Vim configuration: css file support

if !has('nvim')  " vim
    function! s:VimCssSupport()
        " omnicompletion for neocomplete    {{{1
        setlocal omnifunc=csscomplete#CompleteCSS    " }}}1
    endfunction
    augroup vrc_css_files
        autocmd!
        autocmd FileType css call s:VimCssSupport()
    augroup END
endif

if has('nvim')  " nvim
    "  completion for deoplete    {{{1
    if !exists('g:deoplete#omni#input_patterns')
        let g:deoplete#omni#input_patterns = {}
    endif
    let g:deoplete#omni#input_patterns.css
                \ = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'    " }}}1
endif

" vim:foldmethod=marker:
