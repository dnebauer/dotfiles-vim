" Vim configuration: deoplete plugin

" Nvim and deoplete only    {{{1
if dn#rc#isVim() || !has('g:loaded_deoplete')
    finish
endif

" Run at startup    {{{1
let g:deoplete#enable_at_startup = 1

" Smartcase    {{{1
let g:deoplete#enable_smart_case  = 1

" Close parentheses automatically    {{{1
let g:neopairs#enable = 1

" Matchers    {{{1
call deoplete#custom#set('_', 'matchers', [
            \ 'matcher_fuzzy',
            \ ]vy)'

" Converters    {{{1
call deoplete#custom#set('_', 'converters', [
            \ 'converter_auto_paren',     'converter_remove_paren',
            \ 'converter_remove_overlap', 'converter_truncate_abbr',
            \ 'converter_truncate_menu',  'converter_auto_delimiter',
            \ ])

" Disabled syntaxes    {{{1
call deoplete#custom#set('_', 'disabled_syntaxes', [
            \ 'Comment', 'String',
            \ ])

" Minimum pattern length    {{{1
call deoplete#custom#set('_', 'min_pattern_length', 3)

" Keywords    {{{1
" - default
if !exists('g:deoplete#keyword_patterns')
    let g:deoplete#keyword_patterns = {}
endif
if empty(g:deoplete#keyword_patterns)
            \ && exists('g:deoplete#_keyword_patterns')
    let g:deoplete#keyword_patterns = g:deoplete#_keyword_patterns
endif
let g:deoplete#keyword_patterns._ = '[a-zA-Z_]\k*\(?'

" Key mappings    {{{1
" - <Tab>: see tab.vim    {{{2

" - <CR> : close popup and save indent    {{{2
inoremap <silent> <CR> <C-r>=<SID>Deoplete_CR()<CR>
function! s:Deoplete_CR()
    return deoplete#close_popup() . "\<CR>"
endfunction

" - <C-l>: refresh copmletion candidates    {{{2
inoremap <expr><C-l> deoplete#refresh()

" - <BS> : close popup and delete backword char    {{{2
inoremap <expr><C-h>
            \ deoplete#mappings#smart_close_popup()."\<C-h>"
inoremap <expr><BS>
            \ deoplete#mappings#smart_close_popup()."\<C-h>"

" - <C-g>: undo completion    {{{2
inoremap <expr><C-g> deoplete#undo_completion()

" Omni completion    {{{1
" - the variables g:deoplete#omni_patterns and
"   g:deoplete#omni#input_patterns have similar purposes
" - plugin author states the differences in
"   https://github.com/Shougo/deoplete.nvim/issues/190
" - g:deoplete#omni_patterns:
"     'It is called by Vim.'
"     'Full compatibility. But you cannot [use] deoplete features.'
"     'It is provided for old omnifunc compatibility.'
"     'You should not use this feature if you can avoid.'
"     'It is Vim script regex.'
" - g:deoplete#omni#input_patterns:
"     'It is called by omni source.'
"     'It is faster and integrated to deoplete.'
"     'But it does not support some of omnifunc.'
"     'It is Python3 regex.'
" - so, prefer g:deoplete#omni#input_patterns
if !exists('g:deoplete#omni_patterns')
    let g:deoplete#omni_patterns = {}
endif

" Input patterns    {{{1
" - default
let g:deoplete#omni#input_patterns
            \ = get(g:,'deoplete#omni#input_patterns',{})

" Sources    {{{1
if !exists('g:deoplete#sources')
    let g:deoplete#sources = {}
endif
" - load all sources (including neosnippets) except tags
let g:deoplete#sources._ = []  " all sources
let g:deoplete#ignore_sources = {'_': ['tag']}

" Filetype-specific completion    {{{1
" - see ft-filetype.vim configuration files    }}}1

" vim:foldmethod=marker:
