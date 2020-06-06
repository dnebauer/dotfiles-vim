" Vim configuration: mail file support

function! s:MailSupport()
    " re-flow text support    {{{1
    " set parameters to be consistent with re-flowing content
    " e.g., in astroid setting mail>format_flowed=true
    setlocal textwidth=72 
    setlocal formatoptions+=q 
    setlocal comments+=nb:>
    " rewrap paragraph using <M-q>, i.e., Alt-q    {{{1
    " - linux terminal key codes for <M-q> not recognised by vim
    " - get terminal key codes using 'cat' or 'sed -n l'
    " - konsole key codes for <M-q> are 'q'
    " - '' is an escape entered in vim with <C-v> then <Esc>
    " - '' is represented in 'set' command with '\<Esc>'
    if has('unix')
        try
            execute "set <M-q>=\<Esc>q"
		catch /^Vim\%((\a\+)\)\=:E518:/  " Unknown option: <M-q>=q
        endtry
    endif
    nnoremap <silent> <M-q> {gq}<Bar>:echo "Rewrapped paragraph"<CR>
    inoremap <silent> <M-q> <Esc>{gq}<CR>a
    " }}}1
endfunction

augroup vrc_mail_files
    autocmd!
    autocmd FileType mail call s:MailSupport()
augroup END

" vim:foldmethod=marker:
