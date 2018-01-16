" Vim configuration: markdown file support

function! s:MarkdownSupport()
    " tagbar support    {{{1
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
    " configure plugins vim-pandoc[-{syntax,after}]    {{{1
    let g:pandoc#filetypes#handled         = ['pandoc', 'markdown']
    let g:pandoc#filetypes#pandoc_markdown = 0
    let g:pandoc#after#modules#enabled     = ['neosnippet']
    let g:pandoc#modules#enabled           = [
                \ 'formatting', 'folding',    'command',
                \ 'templates',  'keyboard',   'bibliographies',
                \ 'yaml',       'completion', 'toc',
                \ 'chdir',      'hypertext']
    let g:pandoc#formatting#mode                            = 'h'
    let g:pandoc#formatting#smart_autoformat_on_cursormoved = 1
    let g:pandoc#command#latex_engine                       = 'xelatex'
    function! VrcPandocOpen(file)
        return 'xdg-open ' . shellescape(expand(a:file,':p'))
    endfunction
    let g:pandoc#command#custom_open    = 'VrcPandocOpen'
    let g:pandoc#command#prefer_pdf     = 1
    let g:pandoc#command#templates_file = VrcVimPath('home')
                \ . '/vim-pandoc-templates'
    let g:pandoc#compiler#command   = 'panzer'
    let g:pandoc#compiler#arguments = '---quiet ---strict'
    " improve sentence text object    {{{1
    call textobj#sentence#init()
    " add system dictionary to word completions    {{{1
    setlocal complete+=k
    " vim omnicompletion    {{{1
    if !has('nvim')
        setlocal omnifunc=htmlcomplete#CompleteTags
    endif    " }}}1
endfunction

augroup vrc_markdown_files
    autocmd!
    autocmd FileType markdown call s:MarkdownSupport()
augroup END

" vim: set foldmethod=marker :
