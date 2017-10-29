" Vim configuration: vim (and vimrc) file support

function! s:VimSupport()
    " linter: vint    {{{1
    if exists(':SyntasticCheck')  " syntastic
        " - ensure vint is installed
        let l:check_cmd = 'python -c "import vint"'
        call system(l:check_cmd)
        if v:shell_error
            let l:install_cmd = 'pip install --upgrade vim-vint'
            let l:feedback = systemlist(l:install_cmd)
            if v:shell_error
                echoerr 'Unable to install vint binary'
                if len(l:feedback)
                    echoerr 'Shell feedback:'
                    for l:line in l:feedback
                        echoerr '  ' . l:line
                    endfor
                endif
            endif
        endif
        call system(l:check_cmd)
        if !v:shell_error
            if !exists('g:syntastic_vim_checkers')
                let g:syntastic_vim_checkers = []
            endif
            if !count(g:syntastic_vim_checkers, 'vint')
                call add(g:syntastic_vim_checkers, 'vint')
            endif
        else
            echoerr "Vim syntax checker 'vint' is not available"
        endif
    endif    " }}}1
    " K command: use internal vim help    {{{1
    setlocal keywordprg=:help    " }}}1
endfunction
" have to wrap next function in exists() check    {{{1
" sourcing .vimrc results in trying to define this
" function it is executing, which results in E127
" 'Cannot redefine function ... It is in use';
" do check for existence before defining    }}}1
if !exists('*s:VimrcSupport')
    function! s:VimrcSupport()
        " reload after changing    {{{1
        source $HOME/.vimrc    " }}}1
    endfunction
endif

augroup vrc_vim_files
    autocmd!
    autocmd FileType vim call s:VimSupport()
    autocmd BufWritePost .vimrc call s:VimrcSupport()
augroup END

" vim: set foldmethod=marker :
