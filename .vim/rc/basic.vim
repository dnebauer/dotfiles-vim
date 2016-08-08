" Vim configuration: basic settings

" Encoding: utf-8                                                      {{{1
" - cannot set in neovim after initialisation
"   see https://github.com/carlhuda/janus/issues/633
" - should not reset after being set
if !exists('g:encoding_set') || !has('nvim')
    set encoding=utf-8
    let g:encoding_set = 1
endif
scriptencoding utf-8
setglobal fileencoding=utf-8

" Language: Australian English                                         {{{1
" - fallback to UK English, then US English, then generic English
" - E197 error means could not set language
try | lang en_AU | catch /^Vim\((\a\+)\)\=:E197:/
    try | lang en_GB | catch /^Vim\((\a\+)\)\=:E197:/
        try | lang en_US | catch /^Vim\((\a\+)\)\=:E197:/
            try | lang en | catch /^Vim\((\a\+)\)\=:E197:/
            endtry
        endtry
    endtry
endtry

" Use ; for : and vice versa                                           {{{1
vnoremap : ;
vnoremap ; :
" - in normal mode must interact with sneak plugin
" - rest of sneak configuration is in nav.vim
nmap <expr> ; sneak#is_sneaking() ? '<Plug>SneakNext' : ':'

" Disable F1 help key                                                  {{{1
nnoremap <F1> <Nop>
inoremap <F1> <Nop>

" Files to ignore when file matching                                   {{{1
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,
            \.ind,.idx,.ilg,.inx,.out,.toc                           " }}}1

" vim: set foldmethod=marker :
