" Vim configuration: tiddlywiki file support

function! s:TiddlywikiSupport()
    " default tiddler tags    {{{1
    " - space-separated list
    " - enclose tag names containing spaces in doubled square brackets
    " - added to tiddler when converting from 'tid' to 'tiddler' style files
    "   using TWTidToTiddler command from tiddlywiki ftplugin
    let g:default_tiddler_tags = '[[Computing]] [[Software]]'  " }}}1
endfunction

augroup vrc_tiddlywiki_files
    autocmd!
    autocmd FileType tiddlywiki call s:TiddlywikiSupport()
augroup END

" vim:foldmethod=marker:
