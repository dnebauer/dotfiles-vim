" Vim configuration: editing

" Clipboard                                                            {{{1
" - PRIMARY X11 selection
"   . vim visual selection (y,d,p,c,s,x, middle mouse button)
"   . used in writing "* register
"   CLIPBOARD X11 selection
"   . X11 cut, copy, paste (Ctrl-c, Ctrl-v)
"   . used in writing "+ register
"   unnamed option
"   . use "* register
"   . available always in vim and nvim
"   unnamedplus option
"   . use "+ register
"   . available in nvim always
"   . available in vim if compiled in [has('unnamedplus')]
set clipboard=unnamed,unnamedplus
if exists(':shell') && !has('unnamedplus')
    set clipboard-=unnamedplus
endif
" Toggle paste : F2                                               {{{1
set pastetoggle=<F2>

" Undo                                                            {{{1
nnoremap <Leader>u :GundoToggle<CR>

" Delete trailing whitespace                                      {{{1
let g:DeleteTrailingWhitespace        = 1
let g:DeleteTrailingWhitespace_Action = 'delete'

" Move visual block up and down : J,K                             {{{1
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Cycle through visual modes : v                                  {{{1
xnoremap <expr> v mode() ==# 'v' ? "\<C-V>"
            \                    : mode() ==# 'V'
            \                        ? 'v'
            \                        : 'V'

" Treat all numerals as decimal                                   {{{1
set nrformats=
" Handle neovim paste behaviour                                   {{{1
" :nnoremap p axx<Esc>i<CR><Esc>k:put<CR>kJhxxJxx
" :nnoremap P ixx<Esc>i<CR><Esc>k:put<CR>kJhxxJxx
" see undojoin
                                                                " }}}1

" vim: set foldmethod=marker :
