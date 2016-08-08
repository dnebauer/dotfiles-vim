" Vim configuration: perl file support

function! s:PerlSupport()
    " tagbar support                                                   {{{1
    " - from https://github.com/majutsushi/tagbar/wiki
    " - based on ctags settings in ctags config file
    " - ctags config file provided by debian package 'dn-ctags-conf'
    let g:tagbar_type_perl = {
            \ 'ctagstype'  : 'perl',
            \ 'kinds'      : ['a:attribute', 't:subtype', 's:subroutines',
            \                 'c:constants', 'e:extends', 'u:use',
            \                 'r:role'],
            \ 'sro'        : '::',
            \ 'kind2scope' : {},
            \ }                                                      " }}}1
    " vim omnicompletion                                               {{{1
    " - plugin: perlomni.vim
    if !exists('g:neocomplete#sources#omni#input_patterns')
        let g:neocomplete#sources#omni#input_patterns = {}
    endif
    let g:neocomplete#sources#omni#input_patterns.perl =
                \ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'       " }}}1
endfunction

augroup vrc_perl_files
    autocmd!
    autocmd FileType perl call s:PerlSupport()
augroup END

" vim: set foldmethod=marker :
