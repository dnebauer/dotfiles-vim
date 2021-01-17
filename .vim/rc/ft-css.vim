" Vim configuration: css file support

if dn#rc#isVim()  " vim
    function! s:VimCssSupport()
        " omnicompletion - yet to set up    {{{1
    endfunction
    augroup vrc_css_files
        autocmd!
        autocmd FileType css call s:VimCssSupport()
    augroup END
endif

if dn#rc#isNvim()  " nvim
    "  completion for deoplete    {{{1
    if !exists('g:deoplete#omni#input_patterns')
        let g:deoplete#omni#input_patterns = {}
    endif
    let g:deoplete#omni#input_patterns.css
                \ = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'    " }}}1
endif

" vim:foldmethod=marker:
