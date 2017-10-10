" Vim configuration: css file support

" vim-specific    {{{1
if exists(':shell')
    function! s:VimCssSupport()
        " omnicompletion for neocomplete (vim)    {{{2
        setlocal omnifunc=csscomplete#CompleteCSS    " }}}2
    endfunction
    augroup vrc_css_files
        autocmd!
        autocmd FileType css call s:VimCssSupport()
    augroup END
endif

" nvim-specific    {{{1
if exists(':terminal')
    "  completion for deoplete (nvim)    {{{2
    if !exists('g:deoplete#omni#input_patterns')
        let g:deoplete#omni#input_patterns = {}
    endif
    let g:deoplete#omni#input_patterns.css
                \ = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'    " }}}2
endif    " }}}1

" vim: set foldmethod=marker :
