" Vim configuration: xml file support

function! s:XmlSupport()
    " fold by syntax                                                   {{{1
    setlocal foldmethod=syntax
    " vim omnicompletion                                               {{{1
    if has('vim')
        setlocal omnifunc=xmlcomplete#CompleteTags
    endif                                                            " }}}1
endfunction

augroup vrc_xml_files
    autocmd!
    autocmd FileType xml call s:XmlSupport()
augroup END

" vim: set foldmethod=marker :
