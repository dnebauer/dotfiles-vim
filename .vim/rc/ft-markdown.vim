" Vim configuration: markdown file support

function! s:MarkdownSupport()
    " tagbar support                                                   {{{1
    " - from https://github.com/majutsushi/tagbar/wiki
    let l:bin = VrcPluginsDir()
                \ . '/repos/github.com'
                \ . '/jszakmeister/markdown2ctags/markdown2ctags.py'
    if filereadable(l:bin)
        let g:tagbar_type_markdown = {
                    \ 'ctagstype'  : 'markdown',
                    \ 'ctagsbin'   : l:bin,
                    \ 'ctagsargs'  : '-f - --sort=yes',
                    \ 'kinds'      : ['s:sections', 'i:images'],
                    \ 'sro'        : '|',
                    \ 'kind2scope' : {'s' : 'section'},
                    \ 'sort'       : 0,
                    \ }
    endif
    " improve sentence text object                                     {{{1
    call textobj#sentence#init()
    " add system dictionary to word completions                        {{{1
    setlocal complete+=k
    " vim omnicompletion                                               {{{1
    if exists(':shell')
        setlocal omnifunc=htmlcomplete#CompleteTags
    endif
    " customise vim-dn-markdown ftplugin                               {{{1
    let g:DN_markdown_linkcolor_print = 'blue'    
    let g:DN_markdown_fontsize_print  = 12                           " }}}1
endfunction

augroup vrc_markdown_files
    autocmd!
    autocmd FileType markdown call s:MarkdownSupport()
augroup END

" vim: set foldmethod=marker :
