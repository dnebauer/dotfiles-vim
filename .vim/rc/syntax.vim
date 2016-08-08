" Vim configuration: syntax checking

" Vim syntax checking with syntastic                                   {{{1
if has('vim')
    " - status line                                                    {{{2
    if !exists('s:edited_statusline')
        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*
    endif
    let s:edited_statusline = 1

    " - location list                                                  {{{2
    "   . always fill location list with found errors
    let g:syntastic_always_populate_loc_list = 1

    " - error window                                                   {{{2
    "   . always display error window when errors are detected
    let g:syntastic_auto_loc_list = 1

    " - when to check                                                  {{{2
    "   . check for errors on opening, closing and quitting
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
endif

" Nvim suntax checking with neomake                                    {{{1
if has('nvim')
    function! s:LintAsYouType()
        if strlen(bufname('%')) > 0
            update
        endif
        Neomake
    endfunction
    augroup vrc_neomake
        autocmd!
        " check on entering and writing buffer
        autocmd BufEnter * Neomake
        " check on text changes ("lint-as-you-type")
        autocmd InsertLeave,TextChanged * call s:LintAsYouType()
    augroup END
endif

" vim: set foldmethod=marker :
