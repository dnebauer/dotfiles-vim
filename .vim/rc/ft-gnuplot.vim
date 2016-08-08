" Vim configuration: gnuplot file support

function! s:GnuplotSupport()
    " force filetype to 'gnuplot' for syntax support                   {{{1
    setlocal filetype=gnuplot                                        " }}}1
endfunction

augroup vrc_gnuplot_files
    autocmd!
    autocmd BufRead,BufNewFile *.plt call s:GnuplotSupport()
augroup END

" vim: set foldmethod=marker :
