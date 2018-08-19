" Vim configuration: file exploring

" Directory of active buffer : %%    {{{1
cnoremap <expr> %%  getcmdtype() == ':' ? expand('%:h').'/' : '%%'
" }}}1

" vim:foldmethod=marker:
