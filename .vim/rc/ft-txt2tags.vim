" Vim configuration: txt2tags file support

function! s:Txt2tagsSupport()
    " force filetype to 'txt2tags' for syntax support                  {{{1
    setlocal filetype=txt2tags                                       " }}}1
endfunction

augroup vrc_txt2tags_files
    autocmd!
    autocmd BufRead,BufNewFile *.t2t call s:Txt2tagsSupport()
augroup END

" vim: set foldmethod=marker :
