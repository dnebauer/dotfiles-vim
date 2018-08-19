" Vim configuration: snippets

" Select snippets set    {{{1
" -disable default neosnippet-snippets
let g:neosnippet#disable_runtime_snippets = { '_' : 1 }
" - use honza snippets (installs to vim-snippets/snippets)
if !exists('g:neosnippet#snippets_directory')
    let g:neosnippet#snippets_directory = []
endif
let s:honza = dn#rc#vimPath('plug')
            \ . '/repos/github.com/honza/vim-snippets'
if !count(g:neosnippet#snippets_directory, s:honza)
    call add(g:neosnippet#snippets_directory, s:honza)
endif

" Snipmate compatability    {{{1
let g:neosnippet#enable_snipmate_compatibility = 1

" Key mappings    {{{1
" - <C-k>: expand or jump to next placeholder    {{{2
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
" - <Tab>: see tab.vim    {{{2

" Marker concealment    {{{1
if has('conceal')
    set conceallevel=2 concealcursor=niv
endif    " }}}1

" vim:foldmethod=marker:
