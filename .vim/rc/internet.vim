" Vim configuration: internet

" openbrowser plugin overrides netrw    {{{1
let g:netrw_nogx = 1  " disable gx mapping in netrw
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)
" }}}1

" vim: set foldmethod=marker :
