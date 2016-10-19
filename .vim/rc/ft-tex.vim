" Vim configuration: tex file support

function! s:TexSupport()
    " nvim completion using deoplete                                   {{{1
    if exists(':terminal')
        " keyword patterns                                             {{{2
        if !exists('let g:deoplete#keyword_patterns')
            let g:deoplete#keyword_patterns = {}
        endif
        let g:deoplete#keyword_patterns.tex = '[^\w|\s][a-zA-Z_]\w*'
        " input patterns                                               {{{2
        if !exists('g:deoplete#omni#input_patterns')
            let g:deoplete#omni#input_patterns = {}
        endif
        let g:deoplete#omni#input_patterns.tex = '\v\\%('
                    \ . '\a*cite\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
                    \ . '|\a*ref%(\s*\{[^}]*|range\s*\{[^,}]*%(}\{)?)'
                    \ . '|hyperref\s*\[[^]]*'
                    \ . '|includegraphics\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
                    \ . '|%(include%(only)?|input)\s*\{[^}]*'
                    \ . ')'
    endif                                                            " }}}1
endfunction

augroup vrc_tex_files
    autocmd!
    autocmd FileType tex,context call a:TexSupport()
augroup END

" vim: set foldmethod=marker :
