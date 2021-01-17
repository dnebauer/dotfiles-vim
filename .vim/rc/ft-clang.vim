" Vim configuration: c, cpp and objective c file support

" nvim-specific    {{{1
if dn#rc#isNvim()
    function! s:VimCCppObjcSupport()
        " set clang dynamic library path    {{{2
        " - unix
        if dn#rc#os() ==# 'unix'
            let s:clang_path = '/usr/lib/llvm-3.6/lib/libclang.so'
            if filereadable(s:clang_path)
                let g:deoplete#sources#clang#libclang_path
                            \ = s:clang_path
            else
                echoerr 'ft-clang.vim: unable to locate '
                            \ . s:clang_path
            endif
        endif
        " set clang header directory path    {{{2
        " - unix
        if dn#rc#os() ==# 'unix'
            let s:clang_header = '/usr/lib/llvm-3.6/lib/clang'
            if isdirectory(s:clang_header)
                let g:deoplete#sources#clang#clang_header
                            \ = s:clang_header
            else
                echoerr 'ft-clang.vim: unable to locate '
                            \ . s:clang_header
            endif
        endif
        " libclang default compile flags    {{{2
        let g:deoplete#sources#clang#flags
                    \ = ['-x', 'c++', '-std=c++11']    " }}}2
    endfunction
    augroup vrc_c_cpp_objc_support
        autocmd!
        autocmd FileType c,cpp,objc call s:VimCCppObjcSupport()
    augroup END
endif    " }}}1

" vim:foldmethod=marker:
