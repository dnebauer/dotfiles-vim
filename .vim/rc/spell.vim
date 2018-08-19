" Vim configuration: spelling

" Word lists    {{{1
set spell spelllang=en_au

" Dictionaries    {{{1
if dn#rc#os() ==# 'unix' && filereadable('/usr/share/dict/words')
    set dictionary-=/usr/share/dict/words
    set dictionary+=/usr/share/dict/words
endif

" Spell check - off at start up    {{{1
set spell!

" Spell check - toggle on and off [N,I] : \st    {{{1
nnoremap <Leader>st :call dn#rc#spellToggle()<CR>
inoremap <Leader>st <Esc>:call dn#rc#spellToggle()<CR>

" Spell check - show status [N,I] : \ss    {{{1
nnoremap <Leader>ss :call dn#rc#spellStatus()<CR>
inoremap <Leader>ss <Esc>:call dn#rc#spellStatus()<CR>

" Spell check - correct next/previous bad word [N] : ]=,[=    {{{1
noremap ]= ]sz=
noremap [= [sz=

" Add custom moby thesaurus (~/.vim/thes/moby.thes)    {{{1
call dn#rc#addThesaurus(dn#rc#vimPath('home') . '/thes/moby.thes')    " }}}1

" vim:foldmethod=marker:
