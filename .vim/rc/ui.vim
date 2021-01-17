" Vim configuration: user interface

" Basic settings    {{{1
" - minimum number of lines visible above/below cursor
set scrolloff=3
" - show mode in last line
set showmode
" - screen flashes instead of beeping
set visualbell
" - highlight line cursor is on
set cursorline
" - assume terminal is fast
set ttyfast
" - no redraw executing macros, etc.
set lazyredraw
" - show the cursor position all the time
set ruler
" - turns on wrapping
set wrap
" - keys moving cursor beyond line end
set whichwrap+=<,>
" - long lines not broken by hard EOL
set formatoptions+=l
" - autoinsert comment headers
set formatoptions+=ro
" - enable word wrap
set linebreak
" - don't wrap words by default
set textwidth=0
" - status line always displayed
set laststatus=2
" - numbers.vim plugin handles relative numbering in normal mode
"   but requires this setting in configuration
set number
" - when tab-completing command show matches above cmd line
"   . list all matches
"   . complete to the longest possible string
set wildmenu
set wildmode=list:longest
" - show (partial) command in status line
set showcmd
" - show matching brackets
set showmatch
" - recommended by vim-gitgutter plugin
set updatetime=250
let g:gitgutter_max_signs = 2000

" GUI options    {{{1
" - a,A = visual selection globally available for pasting,
" - g = inactive menu items display but greyed out,
" - i = use vim icon,
" - m = show menu bar,
" - L = left scrollbar if vertical split,
" - t = include tearoff menu items,
" - T = include toolbar
" * suppress R scrollbar to prevent 'resize on startup' bug
"   that occurred ~ ver 1:6.3-013+2
set guioptions=aAgimLtT

" Console menu (<F4>)    {{{1
if !has('gui_running')
    source $VIMRUNTIME/menu.vim
    set wildmenu
    set cpo-=<
    set wcm=<C-Z>
    nnoremap <F4> :emenu <C-Z>
endif

" Fonts    {{{1
" - useful utilities for determining fonts: xfontsel, xlsfonts
" - guifont: any spaces after commas must be escaped
"            cannot use quotes around font name
if has('gui_running')
    if dn#rc#os() ==# 'unix'
        set guifont=Andale\ Mono\ 18,
                    \\ FreeMono\ 16,
                    \\ Courier\ 18,
                    \\ Bitstream\ Vera\ Sans\ Mono\ 16,
                    \\ Monospace\ 18
    endif
    if dn#rc#os() ==# 'windows'
        set guifont=Bitstream\ Vera\ Sans\ Mono:h10
    endif
else  " no gui
    set guifont=-unknown-freesans-medium-r-normal--0-0-0-0-p-0-iso10646-1
endif

" Outline viewer (<F8>)    {{{1
nnoremap <F8> :TagbarToggle<CR>

" Colour scheme    {{{1
" - set colour schemes    {{{2
"   1 - gui/gvim = solarized|peaksea|desert|hybrid|railscasts|zenburn|
"                  lucius|atelierheath|atelierforest|papercolor
"   2 - term/vim = solarized|peaksea|desert|hybrid|railscasts|zenburn|
"                  lucius|papercolor
call dn#rc#setColorScheme('peaksea', 'desert')
" - toggle between light and dark schemes (<F5>)
"   . some colour schemes support switching between light and dark
"     schemes, e.g., solarized
"   . if the current scheme does not support switching, then vim
"     may load the default colour scheme before toggling
if exists('*togglebg#map')
    call togglebg#map('<F5>')
endif

" Status line    {{{1
" - vcs integration
let g:airline#extensions#branch#enabled              = 1
let g:airline#extensions#branch#empty_message        = ''
let g:airline#extensions#branch#displayed_head_limit = 10
let g:airline#extensions#branch#format               = 2
" - tagbar integration
let g:airline#extensions#tagbar#enabled = 1
" - use powerline fonts
let g:airline_powerline_fonts = 1
" - set symbols
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" - set unicode symbols
let g:airline_left_sep           = '»'
let g:airline_left_sep           = '▶'
let g:airline_right_sep          = '«'
let g:airline_right_sep          = '◀'
let g:airline_symbols.linenr     = '␊'
let g:airline_symbols.linenr     = '␤'
let g:airline_symbols.linenr     = '¶'
let g:airline_symbols.branch     = '⎇'
let g:airline_symbols.paste      = 'ρ'
let g:airline_symbols.paste      = 'Þ'
let g:airline_symbols.paste      = '∥'
let g:airline_symbols.whitespace = 'Ξ'
" - set airline symbols
let g:airline_left_sep         = ''
let g:airline_left_alt_sep     = ''
let g:airline_right_sep        = ''
let g:airline_right_alt_sep    = ''
let g:airline_symbols.branch   = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr   = ''
" - display all buffers when only one is open
let g:airline#extensions#tabline#enabled = 1    " }}}1

" vim:foldmethod=marker:
