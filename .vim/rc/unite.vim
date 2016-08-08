" Vim configuration: unite plugin and helpers

" Map prefix                                                           {{{1
nnoremap [unite] <Nop>
nmap , [unite]
" General settings                                                     {{{1
augroup vrc_unite_settings
    autocmd!
    autocmd FileType unite call s:UniteSettings()
augroup END
function! s:UniteSettings()
    " exit with Esc
    nmap <buffer> <ESC>  <Plug>(unite_exit)
    " supertab integration
    let b:SuperTabDisabled = 1
    " suppress regular buffer features
    setlocal noswapfile
    setlocal undolevels=-1
endfunction
" Prompt function                                                      {{{1
function! s:Prompt()
    echo 'Press any key to continue...'
    call getchar()
    redraw
endfunction
" - ,b : source = buffers                                              {{{1
nnoremap <silent> [unite]b :<C-u>Unite
            \ -buffer-name=buffers
            \ -quick-match
            \ buffer<CR>
" - ,B : source = bibtex references                                    {{{1
nnoremap <silent> [unite]B :call <SID>Unite_BibTeX()<CR>
function! s:Unite_BibTeX()
    let l:errors = []
    " check: have pybtex
    if !executable('pybtex')
        call add(l:errors, "Cannot run without 'pybtex'")
    endif
    " check: at least one valid bibtex file
    if exists('g:unite_bibtex_bib_files')
        if type(g:unite_bibtex_bib_files) != type([])
            call add(l:errors, 'g:unite_bibtex_bib_files must be a List')
        endif
        " filter out invalid filepaths
        call filter(g:unite_bibtex_bib_files, 'filereadable(v:val)')
    else
        let g:unite_bibtex_bib_files = []
    endif
    if empty(g:unite_bibtex_bib_files)
        call add(l:errors, 'No valid bibtex files specified')
        call add(l:errors, 'Add valid bibtex filepath(s) to '
                    \      . "'g:unite_bibtex_bib_files' List")
    endif
    " if errors detected, display messages and exit
    if !empty(l:errors)
        redraw
        for l:error in l:errors
            echomsg l:error
        endfor
        return
    endif
    " succeeded, so:
    " - inform user
    if len(g:unite_bibtex_bib_files) == 1
        echomsg 'Using bibtex file: ' . g:unite_bibtex_bib_files
    else
        echomsg 'Using bibtex files: '
        for l:file in g:unite_bibtex_bib_files
            echomsg '  ' . l:file
        endfor
    endif
    call s:Prompt()
    " - remap ',B' to run unite command next time
    nnoremap <silent> [unite]B :<C-u>Unite
                \ -buffer-name=bibtex
                \ bibtex<CR>
    " - run unite command this time
    Unite -buffer-name=bibtex bibtex
endfunction
" - ,c : source = command history                                      {{{1
nnoremap [unite]c :<C-u>Unite
            \ -buffer-name=commands
            \ history/command<CR>
" - ,f : source = file search                                          {{{1
if VrcOS() ==# 'windows'
    nnoremap <silent> [unite]f :call <SID>Unite_Find_on_Windows()<CR>
    function! s:Unite_Find_on_Windows()
        " possible utilities to use:
        " - Silver Searcher (ag)
        "   https://github.com/ggreer/the_silver_searcher
        " - Platinum Searcher (pt)
        "   https://github.com/monochromegane/the_platinum_searcher
        " they are listed in preference order
        let l:utils = [
                    \  {
                    \   'utility': 'Silver Searcher',
                    \   'exename': 'ag',
                    \   'command': ['ag', '--follow', '--nocolor',
                    \               '--nogroup', '--hidden', '-g'],
                    \   'findarg': [],
                    \  },
                    \  {
                    \   'utility': 'Platinum Searcher',
                    \   'exename': 'pt',
                    \   'command': ['pt', '--follow', '--nocolor',
                    \               '--nogroup', '--hidden', '-g'],
                    \   'findarg': [],
                    \  },
                    \ ]
        " look for utility to use
        let l:found_util = 0
        for l:util in l:utils
            if executable(l:util.exename)
                let l:found_util                     = 1
                let g:unite_source_rec_async_command = l:util.command
                let g:unite_source_rec_find_args     = l:util.findarg
                break
            endif
        endfor
        " exit if no utility found to run
        if !l:found_util
            echomsg "Can't find any of these utilities to use:"
            for l:util in l:utils
                echomsg '  ' . l:util.utility
                            \ . ' (' . l:util.exename . ')'
            endfor
            return
        endif
        " succeeded, so:
        " - inform user
        redraw
        echomsg 'Using grep command: '
                    \ . join(g:unite_source_rec_async_command, ' ')
        call s:Prompt()
        " - remap ',f' to run unite command next time
        nnoremap [unite]f :<C-u>Unite
                    \ -buffer-name=files
                    \ file_rec/async:!<CR>
        " - run unite command this time
        Unite -buffer-name=files file_rec/async:!
    endfunction
else
    nnoremap <silent> [unite]f :<C-u>Unite
                \ -buffer-name=files
                \ file_rec/async:!<CR>
endif
" - ,F : source = recent files                                         {{{1
nnoremap <silent> ,F :<C-u>Unite
            \ -buffer-name=recent
            \ file_mru<CR>
" - ,g : source = grep files                                           {{{1
nnoremap [unite]g :call <SID>Unite_Grep()<CR>
function! s:Unite_Grep()
    " possible utilities to use, in preference order
    " - Silver Searcher (ag)
    "   https://github.com/ggreer/the_silver_searcher
    " - Platinum Searcher (pt)
    "   https://github.com/monochromegane/the_platinum_searcher
    " - ack-grep (ack-grep)
    "   http://beyondgrep.com/
    " - Highway (hw)
    "   https://github.com/tkengo/highway
    " they are listed in order of preference
    let l:utils = [
                \  {
                \   'utility': 'Silver Searcher',
                \   'exename': 'ag',
                \   'default': "-i --vimgrep --hidden --ignore '.hg' "
                \              . " --ignore '.svn' --ignore '.git' "
                \              . " --ignore '.bzr' --smart-case",
                \   'recurse': '',
                \  },
                \  {
                \   'utility': 'Platinum Searcher',
                \   'exename': 'pt',
                \   'default': '--nogroup --nocolor',
                \   'recurse': '',
                \  },
                \  {
                \   'utility': 'ack-grep',
                \   'exename': 'ack-grep',
                \   'default': '-i --no-heading --no-color -k -H',
                \   'recurse': '',
                \  },
                \  {
                \   'utility': 'Highway',
                \   'exename': 'hw',
                \   'default': '--no-group --no-color',
                \   'recurse': '',
                \  },
                \ ]
    " look for utility to use
    let l:found_util = 0
    for l:util in l:utils
        if executable(l:util.exename)
            let l:found_util                      = 1
            let g:unite_source_grep_command       = l:util.exename
            let g:unite_source_grep_default_opts  = l:util.default
            let g:unite_source_grep_recursive_opt = l:util.recurse
            break
        endif
    endfor
    " exit if no utility found to run
    if !l:found_util
        echomsg "Can't find any of these utilities to use:"
        for l:util in l:utils
            echomsg '  ' . l:util.utility . ' (' . l:util.exename . ')'
        endfor
        return
    endif
    " succeeded, so:
    " - inform user
    redraw
    echomsg 'Using grep command: ' . g:unite_source_grep_command
                \ . ' ' . g:unite_source_grep_default_opts
    call s:Prompt()
    " - remap ',g' to run unite command next time
    nnoremap [unite]g :<C-u>Unite
                \ -buffer-name=grep
                \ grep<CR>
    " - run unite command this time
    Unite -buffer-name=grep grep
endfunction
" - ,h : source = help on word under cursor                            {{{1
nnoremap <silent> [unite]h :<C-u>UniteWithCursorWord
            \ -buffer-name=help
            \ help<CR>
" - ,H : source = help on entered word                                 {{{1
nnoremap <silent> [unite]H :<C-u>Unite
            \ -buffer-name=help
            \ help<CR>
" - ,m : source = mappings                                             {{{1
nnoremap <silent> [unite]m :<C-u>Unite
            \ -buffer-name=mappings
            \ mapping<CR>
" - ,o : source = outline                                              {{{1
nnoremap <silent> [unite]o :<C-u>Unite
            \ -buffer-name=outline
            \ outline<CR>
" - ,r : source = register                                             {{{1
nnoremap <silent> [unite]r :<C-u>Unite
            \ -buffer-name=registers
            \ -quick-match
            \ register<CR>
" - ,s : source = search history                                       {{{1
nnoremap <silent> [unite]s :<C-u>Unite
            \ -buffer-name=search
            \ history/search<CR>
" - ,t : source = tags                                                 {{{1
nnoremap <silent> [unite]t :<C-u>Unite
            \ -buffer-name=tags
            \ tag:%<CR>
" - ,u : source = [blank]                                              {{{1
nnoremap [unite]u :<C-u>Unite
" - ,U : source = unicode                                              {{{1
nnoremap <silent> [unite]U :<C-u>Unite
            \ -buffer-name=unicode
            \ unicode<CR>
" - ,y : source = yank history                                         {{{1
let g:unite_source_history_yank_enable = 1
nnoremap <silent> [unite]y :<C-u>Unite
            \ -buffer-name=yank
            \ history/yank<CR>
                                                                     " }}}1

" vim: set foldmethod=marker :
