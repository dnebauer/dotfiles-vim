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

" Find all matches in line                                             {{{1
" - 'g' now toggles to first only
set gdefault

" Progressive match with incremental search                            {{{1
set incsearch

" Force normal regex during search                                     {{{1
nnoremap / /\v
nnoremap ? ?\v

" Selected text                                                        {{{1
" - search for selected text [V] : /,?
vnoremap / y/\v<C-R>"<CR>
vnoremap ? y?\v<C-R>"<CR>
" - extend selection to next match [V] : /,?
"   . currently only works on forward search ('/'), not reverse ('#')
" function VrcCmd(cmd)                                                 {{{2
" intent: execute command line command
" params: cmd - command
" return: nil
function! VrcCmd(cmd)
    execute 'menu Foo.Bar :' . a:cmd
    emenu Foo.Bar
    unmenu Foo
endfunction                                                          " }}}2
" function VrcVisual(direction)                                        {{{2
" visual selection is used for various searches
" params: direction - direction or type ['f'|'b'|'gv'|replace']
" return: nil
function! VrcVisual(direction) range
    " store away contents of unnamed register and save selection to it
    let l:saved_reg = @"
    execute 'normal! vgvy'
    " tidy up selection by escaping control characters and removing newlines
    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", '', '')
    " extend selection forwards to next match on current selection
    if     a:direction ==# 'f'
        execute 'normal /' . l:pattern . '<CR>'
    " extend selection backwards to next match on current selection
    elseif a:direction ==# 'b'
        execute 'normal 2?' . l:pattern . '<CR>'
    " search current directory recursively for selection
    elseif a:direction ==# 'gv'
        call VrcCmd('vimgrep ' . '/' . l:pattern . '/' . ' **/*')
    " make selection target for substitution
    elseif a:direction ==# 'replace'
        call VrcCmd('%s' . '/'. l:pattern . '/')
    endif
    " save selection to last search pattern register
    let @/ = l:pattern
    " restore unnamed register contents
    let @" = l:saved_reg
endfunction                                                          " }}}2
vnoremap <silent> * :call VrcVisual('f')<CR>
vnoremap <silent> # :call VrcVisual('b')<CR>
" - search cwd recursively for selected text (vimgrep) [V] : gv
vnoremap <silent> gv :call VrcVisual('gv')<CR>
" - make selected text target of a substitution command [V] : \r
vnoremap <silent> <Leader>r :call VrcVisual('replace')<CR>

" Mute search highlighting as part of screen redraw                    {{{1
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
                                                                     " }}}1

" vim: set foldmethod=marker :
