" Vim configuration: json file support

function! s:JsonSupport()
    " fold on {...} and [...] blocks    {{{1
    setlocal foldmethod=syntax    " }}}1
endfunction

augroup vrc_json_files
    autocmd!
    autocmd FileType json,jsonl,jsonp call s:JsonSupport()
augroup END

" vim:foldmethod=marker:
