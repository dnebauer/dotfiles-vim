" Vim configuration: javascript file support

function! s:JavascriptSupport()
    " vim omnicompletion with neocomplete                              {{{1
    if has('vim')
        setlocal omnifunc=javascriptcomplete#CompleteJS
        " these vars suggested on carlitux/deoplete-ternjs github readme
        if !exists('g:tern#command') | let g:tern#command = [] | endif
        if !count(g:tern#command, 'tern')
            call add(g:tern#command, 'tern')
        endif
        if !exists('g:tern#arguments') | let g:tern#arguments = [] | endif
        if !count(g:tern#arguments, '--persistent')
            call add(g:tern#arguments, '--persistent')
        endif
    endif

    " nvim completion using deoplete                                   {{{1
    if has('nvim')
        if !exists('g:deoplete#omni#input_patterns')
            let g:deoplete#omni#input_patterns = {}
        endif
        let g:deoplete#omni#input_patterns.javascript = '[^. \t]\.\w*'
        " these vars suggested on carlitux/deoplete-ternjs github readme
        let g:tern_request_timeout       = 1
        let g:tern_show_signature_in_pum = 0  " disable full signature
    endif                                                            " }}}1
endfunction

augroup vrc_javascript_files
    autocmd!
    autocmd FileType javascript call s:JavascriptSupport()
augroup END

" vim: set foldmethod=marker :
