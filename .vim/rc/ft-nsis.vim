" Vim configuration: nsis file support

function! s:NsisSupport()
    " autodetect nsis header files    {{{1
    " - vim autodetects nsis script files ('*.nsi') as filetype 'nsis'
    " - vim does not autodetect nsis header files ('*.nsh') filetype
    setlocal filetype=nsis    " }}}1
endfunction

augroup vrc_nsis_files
    autocmd!
    autocmd BufRead,BufNewFile *.nsh call s:NsisSupport()
augroup END

" vim:foldmethod=marker:
