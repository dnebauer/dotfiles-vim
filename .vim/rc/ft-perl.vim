" Vim configuration: perl file support

function! s:PerlSupport()
    " tagbar support    {{{1
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
            \ }    " }}}1
    " linting    {{{1
    " ale    {{{2
    " - include t/lib in module search path    {{{3
    let g:ale_perl_perl_options = '-c -Mwarnings -Ilib -It/lib'
    " - show Perl::Critic rules that are violated    {{{3
    let g:ale_perl_perlcritic_showrules = 1
    " - display Perl::Critic violations as warnings, not errors    {{{3
    if !exists('g:ale_type_map') | let g:ale_type_map = {} | endif
    let g:ale_type_map.perlcritic = {'ES': 'WS', 'E': 'W'}
    " syntax highlighting    {{{1
    " [vim-perl (perl.vim) settings - see |ft-perl-syntax|]
    " - inline POD highlighting
    let g:perl_include_pod = 1
    " - highlight complex expressions
    let g:perl_extended_vars = 1
    " - use more context for highlighting
    let g:perl_sync_dist = 250
    " }}}1
endfunction

augroup vrc_perl_files
    autocmd!
    autocmd FileType perl call s:PerlSupport()
augroup END

" vim:foldmethod=marker:
