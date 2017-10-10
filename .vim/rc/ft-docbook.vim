" Vim configuration: docbook file support

function! s:DocbookSupport()
    " fold by syntax    {{{1
    setlocal foldmethod=syntax
    " syntax checking    {{{1
    " - used by vim-dn-docbk ftplugin
    let g:dn_docbk_relaxng_schema =
                \ '/usr/share/xml/docbook/schema/rng/5.0/docbook.rng'
    let g:dn_docbk_schematron_schema =
                \ '/usr/share/xml/docbook/schema/schematron/'
                \ . '5.0/docbook.sch'
    if VrcOS() ==# 'unix'
        let g:dn_docbook_xml_catalog
                    \ = $HOME . '/.config/docbk/catalog.xml'
    endif
    " snippets    {{{1
    if !exists('g:neosnippet#snippets_directory')
        let g:neosnippet#snippets_directory = []
    endif
    let l:repo = VrcVimPath('plug')
                \ . '/repos/github.com/jhradilek/vim-snippets/snippets'
    if !count(g:neosnippet#snippets_directory, l:repo)
        call add(g:neosnippet#snippets_directory, l:repo)
    endif    " }}}1
endfunction

augroup vrc_docbook_files
    autocmd!
    autocmd FileType docbk call s:DocbookSupport()
augroup END

" vim: set foldmethod=marker :
