" Vim configuration: javascript file support

function! s:JavascriptSupport()
    " vim omnicompletion - yet to set up    {{{1
    if dn#rc#isVim()
        " stub
    endif

    " nvim completion using deoplete    {{{1
    if dn#rc#isNvim()
        if !exists('g:deoplete#omni#input_patterns')
            let g:deoplete#omni#input_patterns = {}
        endif
        let g:deoplete#omni#input_patterns.javascript = '[^. \t]\.\w*'
        " these vars suggested on carlitux/deoplete-ternjs github readme
        let g:tern_request_timeout       = 1
        let g:tern_show_signature_in_pum = 0  " disable full signature
    endif    " }}}1
endfunction

augroup vrc_javascript_files
    autocmd!
    autocmd FileType javascript call s:JavascriptSupport()
augroup END

" vim:foldmethod=marker:
