" Vim configuration: conf (configuration) file support

function! s:ConffileSupport()
    " force filetype to 'dosini' for syntax support                    {{{1
    setlocal filetype=dosini                                         " }}}1
endfunction

augroup vrc_conf_files
    autocmd!
    autocmd BufRead,BufNewFile *.conf call s:ConffileSupport()
augroup END

" vim: set foldmethod=marker :
