" Vim configuration: markdown file support

scriptencoding utf8  " required for C-Space mapping

function! s:MarkdownSupport()
    " tagbar support    {{{1
    " - from https://github.com/majutsushi/tagbar/wiki
    let l:bin = dn#rc#pluginsDir()
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
                \ 'formatting', 'folding', 'command',
                \ 'keyboard',   'yaml',    'completion',
                \ 'toc',        'chdir',   'hypertext']
    let g:pandoc#formatting#mode                            = 'h'
    let g:pandoc#formatting#smart_autoformat_on_cursormoved = 1
    let g:pandoc#command#latex_engine                       = 'xelatex'
    let g:pandoc#command#custom_open    = 'dn#rc#pandocOpen'
    let g:pandoc#command#prefer_pdf     = 1
    let g:pandoc#command#templates_file = dn#rc#vimPath('home')
                \ . '/vim-pandoc-templates'
    let g:pandoc#compiler#command   = 'panzer'
    let g:pandoc#compiler#arguments = '---quiet ---strict'
                \ . ' ---panzer-support ' . dn#rc#panzerPath()
    " insert hard space    {{{1
    " - map unicode non-breaking space to C-Space
    " - would prefer C-S-Space but terminal vim has a problem with mapping it
    "   (see https://vi.stackexchange.com/a/13329 for details)
    inoremap <buffer><silent><C-Space>  
    " improve sentence text object    {{{1
    call textobj#sentence#init()
    " add system dictionary to word completions    {{{1
    setlocal complete+=k
    " vim omnicompletion    {{{1
    if !has('nvim')
        setlocal omnifunc=htmlcomplete#CompleteTags
    endif    " }}}1
    " change filetype to trigger vim-pandoc plugin
    set filetype=markdown.pandoc
endfunction

augroup vrc_markdown_files
    autocmd!
    autocmd FileType markdown call s:MarkdownSupport()
augroup END

" vim:foldmethod=marker:
