" Vim configuration: aligning text

" Tabs                                                                 {{{1
" - set tab = 4 spaces
set tabstop=4
set softtabstop=4
" - force spaces for tabs
set expandtab

" Indenting                                                            {{{1
" - copy indent from current line to new
set autoindent
" - attempt intelligent indenting
set smartindent
" - number of spaces to use for autoindent
set shiftwidth=4

" Align text                                                           {{{1
" - align text on '=' and ':'
nnoremap <leader>a= :Tabularize /=<CR>
vnoremap <leader>a= :Tabularize /=<CR>
nnoremap <leader>a: :Tabularize /:\zs<CR>
vnoremap <leader>a: :Tabularize /:\zs<CR>
                                                                     " }}}1

" vim: set foldmethod=marker :
