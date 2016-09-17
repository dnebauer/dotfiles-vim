" Vim configuration: search

" Highlighting matches                                                 {{{1
" - highlight all current matches
set hlsearch
" - don't highlight previous matches initially
set highlight=ln
" - turn off match highlighing [N] : \<Space><Space>
nnoremap <silent> <Leader><Space><Space> :nohlsearch<CR>

" Case sensitivity                                                     {{{1
" - case insensitive matching if all lowercase
set ignorecase
" - case sensitive matching if any capital letters
set smartcase
" - intelligent case selection in autocompletion
set infercase

" Find all matches in line                                             {{{1
" - 'g' now toggles to first only
set gdefault

" Progressive match with incremental search                            {{{1
set incsearch

" Force normal regex during search                                     {{{1
nnoremap / /\v
nnoremap ? ?\v

" Mute search highlighting as part of screen redraw                    {{{1
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Fix '&' command                                                      {{{1
" - unlike '&', '&&' preserves flags
" - create visual mode equivelent
nnoremap & :&&<CR>
xnoremap & :&&<CR>
                                                                     " }}}1

" vim: set foldmethod=marker :
