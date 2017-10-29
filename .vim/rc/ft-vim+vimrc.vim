" Vim configuration: vim (and vimrc) file support

function! s:VimSupport()
    " K command: use internal vim help    {{{1
    setlocal keywordprg=:help    " }}}1
endfunction
" have to wrap next function in exists() check    {{{1
" sourcing .vimrc results in trying to define this
" function it is executing, which results in E127
" 'Cannot redefine function ... It is in use';
" do check for existence before defining    }}}1
if !exists('*s:VimrcSupport')
    function s:VimrcSupport()
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
