" Vim configuration: syntax checking

function! s:BufferIsFile()    " {{{1
    return strlen(bufname('%')) > 0
endfunction

" note on E676 error    {{{1

" Nvim can give an E676 error ('No matching commands for acwrite buffer'),
" even though there ARE matching autocommands, when editing buffers with
" filetype 'acwrite'.
" The 'acwrite' filetype is set by the vim-gnupg plugin
" when editing '*.gpg' files.
" This error should be caught and handled when
" setting autocommands.

" Ale    {{{1
if dn#rc#lintEngine() ==# 'ale'
    " integrate with airline    {{{2
    let g:airline#extensions#ale#enabled = 1
    " save file after alteration    {{{2
    " - because some linters can't be run on buffer contents, only saved file
    " - handle E676 error as described above
    function! s:SaveAfterAlteration()
        "if s:BufferIsFile()
        if strlen(bufname('%')) > 0
            try | update | catch /^Vim\%((\a\+)\)\=:E676/ | endtry
        endif
    endfunction
    augroup vrc_ale
        autocmd!
        autocmd InsertLeave,TextChanged * call s:SaveAfterAlteration()
    augroup END    " }}}2
endif

" Neomake    {{{1
if dn#rc#lintEngine() ==# 'neomake'
    " check on buffer entry and text change (lint-as-you-type)    {{{2
    " - handle E676 error as described above
    function! s:LintAsYouType()
        if s:BufferIsFile()
            try
                update
            catch /^Vim\%((\a\+)\)\=:E676/
            endtry
        endif
        Neomake
    endfunction
    augroup vrc_neomake
        autocmd!
        " check on entering and writing buffer
        autocmd BufEnter * Neomake
        " check on text changes ("lint-as-you-type")
        autocmd InsertLeave,TextChanged * call s:LintAsYouType()
        autocmd BufWriteCmd,FileWriteCmd,FileAppendCmd * call s:LintAsYouType()
    augroup END    " }}}2
endif

" Syntastic    {{{1
if dn#rc#lintEngine() ==# 'syntastic'
    " - status line    {{{2
    if !exists('s:edited_statusline')
        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*
    endif
    let s:edited_statusline = 1

    " - location list    {{{2
    "   . always fill location list with found errors
    let g:syntastic_always_populate_loc_list = 1

    " - error window    {{{2
    "   . always display error window when errors are detected
    let g:syntastic_auto_loc_list = 1

    " - when to check    {{{2
    "   . check for errors on opening, closing and quitting
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
endif    " }}}1

" vim: set foldmethod=marker :
