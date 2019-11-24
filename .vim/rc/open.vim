" Vim configuration: startup

" Display warning if opening a file that is a symlink    {{{1
augroup vrc_initial_filepath
    autocmd!
    autocmd BufNewFile,BufReadPost *
                \ let b:vrc_initial_cfp = simplify(expand('%'))
augroup END
augroup vrc_buffer_file_symlink
    autocmd!
    autocmd BufNewFile,BufReadPost * call dn#rc#symlinkWarning()
augroup END

" Change to document directory    {{{1
augroup vrc_local_dir
    autocmd!
    autocmd BufEnter * call dn#rc#cdToLocalDir()
augroup END    " }}}1

" vim:foldmethod=marker:
