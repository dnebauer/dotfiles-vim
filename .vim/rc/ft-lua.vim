" Vim configuration: lua file support

function! s:LuaSupport()
    " nvim completion using deoplete    {{{1
    if has('nvim')
        if !exists('g:deoplete#omni#functions')
            let g:deoplete#omni#functions = {}
        endif
        let g:deoplete#omni#functions.lua = 'xolox#lua#omnifunc'
    endif
    " linting    {{{1
    " ale    {{{2
    if dn#rc#lintEngine() ==# 'ale'
        let g:ale_lua_luacheck_options = '--no-unused-args'
    endif
    " syntastic    {{{2
    if dn#rc#lintEngine() ==# 'syntastic'
        let g:syntastic_check_on_open     = 1
        let g:syntastic_lua_checkers      = ['luac', 'luacheck']
        let g:syntastic_lua_luacheck_args = '--no-unused-args'
    endif
    " }}}1
endfunction

augroup vrc_lua_files
    autocmd!
    autocmd FileType lua call s:LuaSupport()
augroup END

" vim: set foldmethod=marker :
