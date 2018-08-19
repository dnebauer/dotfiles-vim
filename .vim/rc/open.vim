" Vim configuration: startup

" Change to document directory    {{{1
augroup vrc_local_dir
    autocmd!
    autocmd BufEnter * call dn#rc#cdToLocalDir()
augroup END    " }}}1

" vim:foldmethod=marker:
