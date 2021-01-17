" Vim configuration: denite plugin and helpers

" Map prefix    {{{1
nnoremap [denite] <Nop>
nmap , [denite]
" Cursor movement    {{{1
" - cursor keys    {{{2
if exists('*denite#custom#map')
call denite#custom#map('insert', '<Down>',
            \ '<denite:move_to_next_line>', 'noremap')
endif
if exists('*denite#custom#map')
call denite#custom#map('insert', '<Up>',
            \ '<denite:move_to_previous_line>', 'noremap')
endif
" - C-n and C-p    {{{2
if exists('*denite#custom#map')
call denite#custom#map('insert', '<C-n>',
            \ '<denite:move_to_next_line>', 'noremap')
endif
if exists('*denite#custom#map')
call denite#custom#map('insert', '<C-p>',
            \ '<denite:move_to_previous_line>', 'noremap')
endif
" General settings    {{{1
augroup vrc_denite_settings
    autocmd!
    autocmd FileType denite call s:DeniteSettings()
augroup END
function! s:DeniteSettings()
    " supertab integration
    let b:SuperTabDisabled = 1
    " suppress regular buffer features
    setlocal noswapfile
    setlocal undolevels=-1
endfunction
" Prompt function    {{{1
function! s:Prompt()
    echo 'Press any key to continue...'
    call getchar()
    redraw
endfunction
" - ,b : source = buffers    {{{1
nnoremap <silent> [denite]b :<C-u>Denite
            \ -buffer-name=buffers
            \ buffer<CR>
" - ,c : source = command history    {{{1
nnoremap <silent> [denite]c :<C-u>Denite
            \ -buffer-name=commands
            \ command_history<CR>
" - ,d : source = [blank]    {{{1
nnoremap [denite]d :<C-u>Denite
" - ,f : source = file search    {{{1
if dn#rc#os() ==# 'windows'
    nnoremap <silent> [denite]f :call <SID>Denite_Find_on_Windows()<CR>
    function! s:Denite_Find_on_Windows()
        " possible utilities to use:
        " - RipGrep (rg)
        "   https://github.com/BurntSushi/ripgrep
        " - Silver Searcher (ag)
        "   https://github.com/ggreer/the_silver_searcher
        " - Platinum Searcher (pt)
        "   https://github.com/monochromegane/the_platinum_searcher
        " they are listed in preference order
        let l:utils = [
                    \  {
                    \   'utility': 'RipGrep',
                    \   'exename': 'rg',
                    \   'command': ['rg', '--follow', '--color', 'never',
                    \               '--hidden', ''],
                    \  },
                    \  {
                    \   'utility': 'Silver Searcher',
                    \   'exename': 'ag',
                    \   'command': ['ag', '--follow', '--nocolor',
                    \               '--nogroup', '--hidden', '-g', ''],
                    \  },
                    \  {
                    \   'utility': 'Platinum Searcher',
                    \   'exename': 'pt',
                    \   'command': ['pt', '--follow', '--nocolor',
                    \               '--nogroup', '--hidden', ((has('win32')
                    \               || has('win64')) ? '-g:' : '-g='), ''],
                    \  },
                    \ ]
        " look for utility to use
        let l:file_rec = {}
        for l:util in l:utils
            if executable(l:util.exename)
                let l:file_rec = deepcopy(l:util)
                break
            endif
        endfor
        " exit if no utility found to run
        if empty(l:file_rec)
            echomsg "Can't find any of these utilities to use:"
            for l:util in l:utils
                echomsg '  ' . l:util.utility
                            \ . ' (' . l:util.exename . ')'
            endfor
            return
        endif
        " succeeded, so:
        " - configure denite accordingly
        call denite#custom#var('file_rec', 'command', l:file_rec.command)
        " - inform user
        redraw
        echomsg 'Using ' l:file_rec.utility . ' (' . l:file_rec.exename
                    \ . ') for grep command'
        call s:Prompt()
        " - remap ',f' to run denite command next time
        nnoremap [denite]f :<C-u>Denite
                    \ -buffer-name=files
                    \ file_rec<CR>
        " - run unite command this time
        Unite -buffer-name=files file_rec
    endfunction
else  " non-windows operating system
    nnoremap <silent> [denite]f :<C-u>Denite
                \ -buffer-name=files
                \ file_rec<CR>
endif
" - ,F : source = recent files    {{{1
nnoremap <silent> [denite]F :<C-u>Denite
            \ -buffer-name=recent
            \ file_mru<CR>
" - ,g : source = grep files    {{{1
nnoremap [denite]g :call <SID>Denite_Grep()<CR>
function! s:Denite_Grep()
    " possible utilities to use, in preference order
    " - ugrep (ugrep)
    "   https://github.com/Genivia/ugrep
    " - Silver Searcher (ag)
    "   https://github.com/ggreer/the_silver_searcher
    " - Platinum Searcher (pt)
    "   https://github.com/monochromegane/the_platinum_searcher
    " - ack (ack)
    "   http://beyondgrep.com/
    " - Highway (hw) is not supported
    " they are listed in order of preference
    let l:utils = [
                \  {
                \   'utility' : 'ugrep',
                \   'command' : ['ugrep'],
                \   'default' : ['-i', '--no-heading', '--no-color',
                \                '-H', '--hidden',
                \                '--exclude-dir={.hg,.svn,.git,.bzr}'],
                \   'recurse' : ['--dereference-recursive'],
                \   'pattern' : [],
                \   'delimit' : ['--'],
                \   'final'   : [],
                \  },
                \  {
                \   'utility' : 'Silver Searcher',
                \   'command' : ['ag'],
                \   'default' : ['-i', '--vimgrep', '--hidden',
                \                '--ignore ''.hg''', '--ignore ''.svn''',
                \                '--ignore ''.git''', '--ignore ''.bzr''',
                \                '--smart-case'],
                \   'recurse' : [],
                \   'pattern' : [],
                \   'delimit' : ['--'],
                \   'final'   : [],
                \  },
                \  {
                \   'utility' : 'Platinum Searcher',
                \   'command' : ['pt'],
                \   'default' : ['--nogroup', '--nocolor', '--smart-case'],
                \   'recurse' : [],
                \   'pattern' : [],
                \   'delimit' : [],
                \   'final'   : [],
                \  },
                \  {
                \   'utility' : 'ack',
                \   'command' : ['ack'],
                \   'default' : ['-i', '--no-heading', '--no-color',
                \                '-k', '-H'],
                \   'recurse' : [],
                \   'pattern' : ['--match'],
                \   'delimit' : [],
                \   'final'   : [],
                \  },
                \ ]
    " look for utility to use
    let l:grep = {}
    for l:util in l:utils
        if executable(l:util.command[0])
            let l:grep = deepcopy(l:util)
            break
        endif
    endfor
    " exit if no utility found to run
    if empty(l:grep)
        echomsg "Can't find any of these utilities to use:"
        for l:util in l:utils
            echomsg '  ' . l:util.utility . ' (' . l:util.command[0] . ')'
        endfor
        return
    endif
    " succeeded, so:
    " - configure denite accordingly
    call denite#custom#var('grep', 'command',        l:grep.command)
    call denite#custom#var('grep', 'default_opts',   l:grep.default)
    call denite#custom#var('grep', 'recursive_opts', l:grep.recurse)
    call denite#custom#var('grep', 'pattern_opt',    l:grep.pattern)
    call denite#custom#var('grep', 'separator',      l:grep.delimit)
    call denite#custom#var('grep', 'final_opts',     l:grep.final)
    " - inform user
    redraw
    echomsg 'Using ' . l:grep.utility . '(' . l:grep.command[0] . ') for grep'
    call s:Prompt()
    " - remap ',g' to run denite command next time
    nnoremap [denite]g :<C-u>Denite -buffer-name=grep grep<CR>
    " - run denite command this time
    Denite -buffer-name=grep grep
endfunction
" - ,h : source = help    {{{1
nnoremap <silent> [denite]h :<C-u>Denite
            \ -buffer-name=help
            \ help<CR>
" - ,o : source = outline    {{{1
nnoremap <silent> [denite]o :<C-u>Denite
            \ -buffer-name=outline
            \ outline<CR>
" - ,r : source = register    {{{1
nnoremap <silent> [denite]r :<C-u>Denite
            \ -buffer-name=registers
            \ register<CR>
" - ,t : source = tags    {{{1
nnoremap <silent> [denite]t :<C-u>Denite
            \ -buffer-name=tags
            \ tag<CR>
" }}}1

" vim:foldmethod=marker:
