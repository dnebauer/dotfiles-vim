" Vim configuration: mail file support

function! s:MailSupport()
    " re-flow text support    {{{1
    " set parameters to be consistent with re-flowing content
    " e.g., in astroid setting mail>format_flowed=true
    setlocal textwidth=72 
    setlocal formatoptions+=q 
    setlocal comments+=nb:>
    " - rewrap paragraph using <M-q>, i.e., Alt-q
    nmap <silent> <M-q> {gq}<Bar>:echo "Rewrapped paragraph"<CR>
    imap <silent> <M-q> <Esc>{gq}<CR>a
    " }}}1
endfunction

augroup vrc_mail_files
    autocmd!
    autocmd FileType mail call s:MailSupport()
augroup END

" vim:foldmethod=marker: