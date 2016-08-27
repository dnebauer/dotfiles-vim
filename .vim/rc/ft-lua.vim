" Vim configuration: lua file support

function! s:LuaSupport()
    " nvim completion using deoplete                                   {{{1
    if has('nvim')
        if !exists('g:deoplete#omni#functions')
            let g:deoplete#omni#functions = {}
        endif
        let g:deoplete#omni#functions.lua = 'xolox#lua#omnifunc'
    endif                                                            " }}}1
endfunction

augroup vrc_lua_files
    autocmd!
    autocmd FileType lua call s:LuaSupport()
augroup END

" vim: set foldmethod=marker :
