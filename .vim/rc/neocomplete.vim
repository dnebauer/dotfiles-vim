" Vim configuration: neocomplete plugin

if !exists('g:loaded_neocomplete')
    finish
endif
" Startup    {{{1
" - disable AutoComplPop to prevent interference
let g:acp_enableAtStartup = 0
" - enable automatically
let g:neocomplete#enable_at_startup = 1

" User experience    {{{1
" - use smartcase
let g:neocomplete#enable_smart_case = 1
" - close parentheses automatically
let g:neopairs#enable = 1
" - minimum syntax keyword length
let g:neocomplete#sources#syntax#min_keyword_length = 3
" - buffers in which to deactivate completion
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Dictionaries    {{{1
let g:neocomplete#sources#dictionary#dictionaries = {
            \   'default'  : '',
            \   'vimshell' : $HOME.'/.vimshell_hist',
            \ }
" Keywords    {{{1
" - define non-default keyword patterns
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Key mappings    {{{1
" - <CR>: close popup and save indent
function! s:VrcCrFunction()
    return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
inoremap <silent> <CR> <C-r>=<SID>VrcCrFunction()<CR>
" - <C-l>: complete common mapping
inoremap <expr><C-l> neocomplete#complete_common_string()
" - <Tab>: see tab.vim
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" - <C-g>: undo completion
inoremap <expr><C-g> neocomplete#undo_completion()

" Sources    {{{1
if !exists('g:neocomplete#sources')
    let g:neocomplete#sources = {}
endif
let g:neocomplete#sources._ = ['buffer', 'member', 'tag', 'file',
            \ 'dictionary', 'neosnippet']

" Omni completion    {{{1
" - recording keyword patterns used in omni completion
"   . hard to understand from help files
"   . using examples from help page 'neocomplete.txt'
" - ensure required variables exist
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
if !exists('g:neocomplete#sources#omni#functions')
    let g:neocomplete#sources#omni#functions = {}
endif
" - filetype-specific omni completion
"   . see ft-filetype.vim configuration files    }}}1

" vim: set foldmethod=marker :
