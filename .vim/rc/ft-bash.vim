" Vim configuration: bash file support

function! s:BashSupport()
    " syntax checker shellcheck follows files ('-x')    {{{1
    " syntastic    {{{2
    if exists(':SyntasticCheck')
        " - ensure relevant variable exists and is a list
        if exists('g:syntastic_bash_shellcheck_args')
            if type(g:syntastic_bash_shellcheck_args) != type([])
                let l:temp = string(g:syntastic_bash_shellcheck_args)
                unlet g:syntastic_bash_shellcheck_args
                let g:syntastic_bash_shellcheck_args = [l:temp]
            endif
        else
            let g:syntastic_bash_shellcheck_args = []
        endif
        " - add argument
        let l:arg = '-x'
        if !count(g:syntastic_bash_shellcheck_args, l:arg)
            call add(g:syntastic_bash_shellcheck_args, l:arg)
        endif
    endif
    " neomake    {{{2
    if exists(':Neomake')
        " - ensure relevant variable exists and is a list
        if exists('g:neomake_bash_shellcheck_args')
            if type(g:neomake_bash_shellcheck_args) != type([])
                let l:temp = string(g:neomake_bash_shellcheck_args)
                unlet g:neomake_bash_shellcheck_args
                let g:neomake_bash_shellcheck_args = [l:temp]
            endif
        else
            let g:neomake_bash_shellcheck_args = []
        endif
        " - add argument
        let l:arg = '-x'
        if !count(g:neomake_bash_shellcheck_args, l:arg)
            call add(g:neomake_bash_shellcheck_args, l:arg)
        endif
    endif    " }}}2
    " }}}1
endfunction

augroup vrc_bash_files
    autocmd!
    autocmd FileType bash call s:BashSupport()
augroup END

" vim: set foldmethod=marker :
