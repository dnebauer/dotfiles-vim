" Vim configuration: MS Windows-specific

" Windows only    {{{1
if dn#rc#os() !=# 'windows'
    finish
endif

" Set mouse and selection behaviour    {{{1
behave mswin

" Set cut, copy and paste keys    {{{1
source $VIMRUNTIME/mswin.vim

" Set diffexpr (no 'diff' in windows)    {{{1
set diffexpr=MyDiff()
function MyDiff()
    let l:opt = '-a --binary '
    if &diffopt =~# 'icase'  | let l:opt.= '-i ' | endif
    if &diffopt =~# 'iwhite' | let l:opt.= '-b ' | endif
    let l:arg1 = v:fname_in
    if l:arg1 =~# ' ' | let l:arg1 = '"' . l:arg1 . '"' | endif
    let l:arg2 = v:fname_new
    if l:arg2 =~# ' ' | let l:arg2 = '"' . l:arg2 . '"' | endif
    let l:arg3 = v:fname_out
    if l:arg3 =~# ' ' | let l:arg3 = '"' . l:arg3 . '"' | endif
    if $VIMRUNTIME =~# ' '
        if &shell =~?'\<cmd'  " looking for cmd.exe
            if empty(&shellxquote)
                let l:shxq_sav = ''
                set shellxquote&
            endif
            let l:cmd = '"' . $VIMRUNTIME . '\diff"'
        else
            let l:cmd = substitute($VIMRUNTIME, ' ', '" ', '')
                        \ . '\diff"'
        endif
    else
        let l:cmd = $VIMRUNTIME . '\diff'
    endif
    silent execute '!' . l:cmd . ' ' . l:opt . l:arg1 . ' '
                \ . l:arg2 . ' > ' . l:arg3
    if exists('l:shxq_sav')
        let &shellxquote=l:shxq_sav
    endif
endfunction    " }}}1

" vim:foldmethod=marker:
