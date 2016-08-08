" Vim configuration: c, cpp and objective c file support

" set clang dynamic library path                                       {{{1
let s:clang_path = '/usr/lib/llvm-3.6/lib/libclang.so'
if filereadable(s:clang_path)
    let g:deoplete#sources#clang#libclang_path = s:clang_path
else
    echoerr 'ft-clang.vim: unable to locate ' . s:clang_path
endif

" set clang header directory path                                      {{{1
let s:clang_header = '/usr/lib/llvm-3.6/lib/clang'
if isdirectory(s:clang_header)
    let g:deoplete#sources#clang#clang_header = s:clang_header
else
    echoerr 'ft-clang.vim: unable to locate ' . s:clang_header
endif

" libclang default compile flags                                       {{{1
let g:deoplete#sources#clang#flags = ['-x', 'c++', '-std=c++11']     " }}}1

" vim: set foldmethod=marker :
