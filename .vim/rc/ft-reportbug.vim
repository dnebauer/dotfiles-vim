" Vim configuration: reportbug file support

function! s:ReportbugSupport()
    " set filetype                                                     {{{1
    " - the debian bug reporting mechanism generates files with the
    "   name stem 'reportbug' which are not given colour syntax
    " - setting filetype to 'mail' works adequately
    setlocal filetype=mail                                           " }}}1
endfunction

augroup vrc_reportbug_files
    autocmd!
    autocmd BufRead reportbug.*,reportbug-* call s:ReportbugSupport()
augroup END

" vim: set foldmethod=marker :
