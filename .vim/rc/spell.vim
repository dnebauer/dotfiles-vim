" Vim configuration: spelling

" Word lists    {{{1
set spell spelllang=en_au

" Dictionaries    {{{1
if VrcOS() ==# 'unix' && filereadable('/usr/share/dict/words')
    set dictionary-=/usr/share/dict/words
    set dictionary+=/usr/share/dict/words
endif

" Spell check - off at start up    {{{1
set spell!

" Spell check - toggle on and off [N,I] : \st    {{{1
" - function VrcMsg(msg, [clear])    {{{2
"   intent: display message in command line
"   params: 1 - message
"           2 - clear message after brief display (boolean, optional)
"   return: nil
function! VrcMsg(msg, ...)
	if mode() ==# 'i' | execute "normal \<Esc>" | endif
	echohl ModeMsg | echo a:msg | echohl Normal
    if a:0 > 0 && a:1 | sleep 1 | execute "normal :\<BS>" | endif
endfunction    " }}}2
" - function VrcSpellStatus()    {{{2
"   intent: display spell check status
"   params: nil
"   return: nil
function! VrcSpellStatus()
    let l:msg = 'spell checking is '
    if &spell
        let l:msg .= 'ON (lang=' . &spelllang . ')'
    else
        let l:msg .= 'OFF'
    endif
    call VrcMsg(l:msg, 1)
endfunction    " }}}2
" - function VrcSpellToggle()    {{{2
"   intent: toggle spell checking
"   params: nil
"   return: nil
function! VrcSpellToggle()
    setlocal spell!
    redraw
    call VrcSpellStatus()
endfunction    " }}}2
nnoremap <Leader>st :call VrcSpellToggle()<CR>
inoremap <Leader>st <Esc>:call VrcSpellToggle()<CR>

" Spell check - show status [N,I] : \ss    {{{1
nnoremap <Leader>ss :call VrcSpellStatus()<CR>
inoremap <Leader>ss <Esc>:call VrcSpellStatus()<CR>

" Spell check - correct next/previous bad word [N] : ]=,[=    {{{1
noremap ]= ]sz=
noremap [= [sz=

" Add custom moby thesaurus (~/.vim/thes/moby.thes)    {{{1
" - function VrcAddThesaurus(thesaurus)    {{{2
"   intent: add thesaurus file
"   params: 1 - thesaurus filepath
"   prints: error message if thesaurus file not found
"   return: nil
function! VrcAddThesaurus(thesaurus)
    " make sure thesaurus file exists
    if strlen(a:thesaurus) == 0
        return
    endif
    if filereadable(resolve(expand(a:thesaurus)))
        " add to thesaurus file variable (string, comma-delimited)
        if strlen(a:thesaurus) > 0
            let &thesaurus .= ','
        endif
        let &thesaurus .= a:thesaurus
    else
        echoerr "Cannot find thesaurus file '" . a:thesaurus . "'"
    endif
endfunction    " }}}2
call VrcAddThesaurus(VrcVimPath('home') . '/thes/moby.thes')    " }}}1

" vim: set foldmethod=marker :
