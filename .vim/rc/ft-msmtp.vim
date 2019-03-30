" Vim configuration: msmtp file support

function! s:MsmtpSupport()
    " set filetype    {{{1
    " - no distinctive file extension or internal syntax
    " - see msmtp package README.Debian for adding vim syntax
    "   support using vim-addons
    setlocal filetype=msmtp    " }}}1
endfunction

augroup vrc_msmtp_files
    autocmd!
    autocmd BufRead ~/.msmtprc call s:MsmtpSupport()
    autocmd BufRead /etc/msmtprc call s:MsmtpSupport()
augroup END

" vim:foldmethod=marker:
