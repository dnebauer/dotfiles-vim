" Configuration file for (n)vim
" - uses subsidiary configuration files in 'rc' subdirectory

" NOTES:    {{{1
" detect whether running vim or nvim    {{{2
" - can no longer test directly for presence of nvim
" - instead test for commands specific to each:
"   . vim:  if exists(':shell')
"   . nvim: if exists(':terminal')    }}}2

" UTILITY FUNCTIONS:    {{{1
" include here only functions that:
" - are used in multiple subsidiary configuration files
" - pass a script variable to a subsidiary configuration file or files
" function VrcOS()    {{{2
" intent: determine operating system
" params: nil
" prints: nil
" return: string ('windows'|'unix'|'other')
function! VrcOS()
    if has('win32') || has ('win64') || has('win95') || has('win32unix')
        return 'windows'
    elseif has('unix')
        return 'unix'
    else
        return 'other'
    endif
endfunction
" function VrcVimPath(type)    {{{2
" intent: provide vim-related paths
" params: type - path type to return ('home'|'plug')
" prints: nil
" return: string (directory path)
function! VrcVimPath(type)
    " vim home directory
    if     a:type ==# 'home'
        let l:os   = VrcOS()
        let l:home = escape($HOME, ' ')
        if     l:os ==# 'windows'
            if exists(':shell')
                return l:home . '/vimfiles'
            else  " nvim
                return resolve(expand('~/AppData/Local/nvim'))
            endif
        elseif l:os ==# 'unix'
            return l:home . '/.vim'
        else
            return l:home . '/.vim'
        endif
    " dein plugin directory root
    elseif a:type ==# 'plug'
        return resolve(expand('~/.cache/dein'))
    " error
    else
        echoerr "Invalid path type '" . a:type . "'"
    endif
endfunction
" function VrcTemp()    {{{2
" intent: return path, name or directory of a temporary file
" params: nil
" prints: nil
" return: string (path element)
function! VrcTemp(part)
    if !exists('s:temp_path') | let s:temp_path = tempname() | endif
    if     a:part ==# 'path' | return s:temp_path
    elseif a:part ==# 'dir'  | return fnamemodify(s:temp_path, ':p:h')
    elseif a:part ==# 'file' | return fnamemodify(s:temp_path, ':p:t')
    else
        echoerr "Invalid VrcTemp param '" . a:part . "'"
    endif
endfunction
" function VrcSource(dir, self)    {{{2
" intent: recursively source vim files in directory
" params: dir  - directory to recursively source
"         self - calling script (resolved filepath)
" prints: files that are not sourced
"         error if passed invalid file name
" return: nil
function! VrcSource(dir, self)
    " dir must exist
    let l:dir = resolve(expand(a:dir))
    if !isdirectory(l:dir)
        echoerr "Invalid source directory '" . l:dir . "'"
        return
    endif
    " recursively process directory contents
    for l:path in glob(l:dir . '/**', 1, 1)
        " ignore if not file
        let l:type = getftype(l:path)
        if l:type !~# 'file\|link' | continue | endif
        " resolve links
        let l:path = (l:type ==# 'link') ? resolve(l:path) : l:path
        " avoid infinite recursion - do not source self!
        if l:path ==# a:self | continue | endif
        " must be vim file
        " - for vim source *.vim; for nvim source *.vim and *.nvim
        let l:match = exists(':shell') ? '^\p\+\.vim$' : '^\p\+\.n\?vim$'
        if fnamemodify(l:path, ':t') =~? l:match
            execute 'source' l:path
        endif
    endfor
endfunction
" function VrcPluginsDir()    {{{2
" intent: provide plugins directory
" params: nil
" prints: nil
" return: plugins directory
function! VrcPluginsDir()
    return VrcVimPath('plug')
endfunction
" function VrcLinterEngine()    {{{2
" intent: provide linter engine
" params: nil
" prints: nil
" return: linter engine ('ale'|'neomake'|'syntastic')
" note:   previous approach relying on detection of commands specific to
"         loaded linting engine, e.g., ':SyntasticCheck' for syntastic,
"         ':Neomake' for neomake and ':ALELint' for ale, did not work because
"         commands are not instantiated when subsidiary configuration are
"         processed
if !exists('*VrcLinterEngine')
    function VrcLinterEngine()
        return 'ale'
    endfunction
endif
" override linter choice in special cases
" syntastic works in vim, but not nvim    {{{3
" - default to neomake if running nvim
if VrcLinterEngine() ==# 'syntastic' && !exists(':shell')
    echomsg 'Cannot use syntastic as linting engine -- it requires vim'
    echomsg 'Instead using neomake as linting engine'
    function! VrcLinterEngine()
        return 'neomake'
    endfunction
endif
" use syntastic for docbk files    {{{3
" - plugin vim-dn-docbk defines custom linters for syntastic
if &filetype ==# 'docbk' && VrcLinterEngine() !=# 'syntastic'
    echomsg 'The vim-dn-docbk plugin uses the syntastic linting engine'
    echomsg 'Switching from ' . VrcLinterEngine() . ' to syntastic'
    function! VrcLinterEngine()
        return 'syntastic'
    endfunction
endif  " }}}3

" PLUGINS:    {{{1
" using github.com/shougo/dein.vim
" python required by several plugins    {{{2
" - in python 3.5 there is no python3 exe installed
if VrcOS() ==# 'windows'
    let s:path = expand('$APPDATA') . '\Local\Programs\Python'
    " python2
    let s:exe = s:path . '\Python27\python.exe'
    if filereadable(s:exe) | let g:python_host_prog = s:exe | endif
    unlet s:exe
    " python3
    let s:exes = [s:path . '\Python35-32\python.exe',
                \ s:path . '\Python35-64\python.exe']
    for s:exe in s:exes
        if filereadable(s:exe)
            let g:python3_host_prog = s:exe
            break
        endif
    endfor
    unlet s:path s:exe s:exes
endif
if exists(':terminal')
    if !has('python')
        echohl WarningMsg | echomsg 'Cannot load Python2' | echohl ErrorMsg
    endif
    if !has('python3')
        echohl WarningMsg | echomsg 'Cannot load Python3' | echohl ErrorMsg
    endif
endif
" dein requirements    {{{2
" - required tools: rsync, git    {{{3
for s:app in ['rsync', 'git']
    if ! executable(s:app)
        echoerr "plugin handler 'dein' can't find '" . s:app . "'"
        echoerr 'aborting vim configuration file execution'
        finish
    endif
endfor
unlet s:app
" - required settings    {{{3
"   vint: -ProhibitSetNoCompatible
set nocompatible
filetype off
" - required vim version    {{{3
if v:version < 704
    echoerr 'this instance of vim is version' . v:version
    echoerr "plugin handler 'dein' needs vim 7.4+"
    echoerr 'aborting vim configuration file execution'
    finish
endif
" how to install/update plugins with dein    {{{2
" - install new plugins
"   . in vim : call dein#install()
"   . shell  : vim "+call dein#install()" +qall
" - update all plugins
"   . in vim : call dein#update()
"   . shell  : vim "+call dein#update()" +qall
" dein events    {{{2
" - VimEnter    {{{3
"   . many important dein-related function calls are made at this event
"   . all post_source hooks are called at VimEnter
" dein configuration    {{{2
" - asynchronous plugin updates    {{{3
"   . when running dein in nvim on windows, updating plugins with the
"     default number of asynchronous processes (8) results in many
"     updates failing
"   . the git operation fails with the message:
"     'Received HTTP code 407 from proxy after CONNECT'
"   . the particular plugins affected in a run are unpredictable, i.e.,
"     a plugin whose update fails in one run will successfully update
"     in the following run
"   . this brute force solution turns off asynchronous updating, so
"     each plugin updates in sequence (but the whole run takes *much*
"     longer)
if exists(':terminal') && VrcOS() ==# 'windows'
    let g:dein#install_max_processes = 1
endif
" set plugin directories    {{{2
let s:dein_dir = VrcPluginsDir() . '/repos/github.com/shougo/dein.vim'
" ensure dein is installed    {{{2
if !isdirectory(s:dein_dir)
    execute '!git clone https://github.com/shougo/dein.vim' s:dein_dir
    echohl WarningMsg
    echomsg 'Execute ''call dein#install()'' once vim loads'
    echohl None
endif
" load dein    {{{2
if &runtimepath !~# '/dein.vim'
    execute 'set runtimepath+=' . s:dein_dir
endif
if dein#load_state(VrcPluginsDir())
    call dein#begin(VrcPluginsDir())
    call dein#add(s:dein_dir)
    call dein#add('shougo/dein.vim')
    " dein commands    {{{2
    call dein#add('haya14busa/dein-command.vim', {
                \ 'on_cmd' : ['Dein'],
                \ })
    " bundles: utilities    {{{2
    " - vimproc : asynchronous execution    {{{3
    "   . build default is 'make' except for MinGW on windows
    let s:vimproc_build_cmd = 'make'
    if executable('mingw32-make')
                \ && ( has('win64') || has('win32') || has('win32unix') )
        let s:vimproc_build_cmd = 'mingw32-make -f ' . (
                    \ has('win64')     ? 'make_mingw64.mak'                :
                    \ has('win32')     ? 'make_mingw32.mak'                :
                    \ has('win32unix') ? 'make_mingw32.mak CC=mingw32-gcc' :
                    \ '' )
    endif
    call dein#add('shougo/vimproc.vim', {
                \ 'build' : s:vimproc_build_cmd,
                \ })
    unlet s:vimproc_build_cmd
    " - neoinclude : completion framework helper    {{{3
    "   . unite has trouble locating neoinclude
    "     unless it is predictably loaded first
    call dein#add('shougo/neoinclude.vim')
    " - dn-utils : general utilities    {{{3
    call dein#add('dnebauer/vim-dn-utils')
    " - repeat : plugin helper for repeating commands    {{{3
    call dein#add('tpope/vim-repeat', {
                \ 'on_source': ['vim-surround'],
                \ })
    " - context_filetype : plugin helper    {{{3
    call dein#add('shougo/context_filetype.vim', {
                \ 'on_source' : ['deoplete.nvim', 'neocomplete.vim',
                \                'echodoc.vim', 'neosnippet.vim'],
                \ 'lazy': 1,
                \ })
    " - bclose : delete buffer without closing window    {{{3
    call dein#add('rbgrouleff/bclose.vim', {
                \ 'on_source' : ['ranger.vim'],
                \ })
    " - fastfold : reduce frequency of folding    {{{3
    "   . required by neocomplete
    call dein#add('konfekt/fastfold')
    " bundles: shell integration    {{{2
    " - vimshell : shell emulation    {{{3
    call dein#add('shougo/vimshell.vim', {
                \ 'depends' : ['vimproc.vim'],
                \ 'on_cmd'  : ['VimShell',           'VimShellCreate',
                \              'VimShellTab',        'VimShellPop',
                \              'VimShellCurrentDir', 'VimShellBufferDir',
                \              'VimShellExecute',    'VimShellInteractive',
                \              'VimShellSendString', 'VimShellSendBuffer',
                \              'VimShellClose'],
                \ })
    " - file-line : open vim on given line    {{{3
    call dein#add('bogado/file-line')
    " - superman : shell uses vim as manpage viewer    {{{3
    call dein#add('dnebauer/vim-superman', {
                \ 'if' : 'has("unix")',
                \ })
    " - eunuch : unix shell commands as vim commands    {{{3
    "   . disable plugin-set autocommands after sourcing because they
    "     a) make all new files executable (not desirable), and
    "     b) insert templates into new files (conflicts with
    "        template plugins)
    call dein#add('tpope/vim-eunuch', {
                \ 'if'               : 'has("unix")',
                \ 'on_cmd'           : ['Remove',    'Unlink', 'Move',
                \                       'Rename',    'Chmod',  'Mkdir',
                \                       'Find',      'Locate', 'Wall',
                \                       'SudoWrite', 'SudoEdit'],
                \ 'hook_post_source' :  'augroup! eunuch',
                \ })
    " - vimpager : unix shell uses vim as pager    {{{3
    "   . sets shell PAGER variable to use vim
    "   . sets alias 'less' to $PAGER
    call dein#add('rkitover/vimpager', {
                \ 'if'     : 'has("unix")',
                \ 'on_cmd' : ['Page'],
                \ })
    " - iron : read-val-print loop (REPL)    {{{3
    call dein#add('hkupty/iron.nvim', {
                \ 'if'     : 'exists(":terminal")',
                \ 'on_cmd' : ['IronRepl', 'IronPromptRepl'],
                \ })
    " - codi : interactive scratchpad (REPL)    {{{3
    "   . TODO: disable linting engines while in codi
    call dein#add('metakirby5/codi.vim', {
                \ 'if'     :   'exists(":terminal") || '
                \            . '(exists("+job") && exists("+channel"))',
                \ 'on_cmd' : ['Codi'],
                \ })
    " bundles: editing    {{{2
    " - unimpaired : various paired mappings    {{{3
    call dein#add('tpope/vim-unimpaired', {
                \ 'depends' : ['vim-repeat'],
                \ })
    " - surround : delete/change surrounding parens, etc.    {{{3
    call dein#add('tpope/vim-surround')
    " - commentary : comment and uncomment lines    {{{3
    call dein#add('tpope/vim-commentary', {
                \ 'on_cmd' : ['Commentary', 'CommentaryLine',
                \             'ChangeCommentary'],
                \ 'on_map' : {'x': ['gc'],
                \             'n': ['gc', 'gcc', 'cgc', 'gcu'],
                \             'o': ['gc']},
                \ })
    " - gundo : undo tree    {{{3
    call dein#add('sjl/gundo.vim', {
                \ 'on_cmd' : ['GundoToggle'],
                \ })
    " - DeleteTrailingWhitespace : delete trailing whitespace    {{{3
    call dein#add('vim-scripts/DeleteTrailingWhitespace')
    " - textobj-entire : select entire content of buffer    {{{3
    "   . requires kana/vim-textobj-user
    "   . cannot load dependency via depends in vim or on_source in nvim
    call dein#add('kana/vim-textobj-user')
    call dein#add('kana/vim-textobj-entire')
    " - unicode : unicode/digraph handling    {{{3
    "   . using 'on_cmd' results in error in airline plugin:
    "     'E117: Unknown function: airline#extensions#unicode#init'
    "   . so load on startup
    call dein#add('chrisbra/unicode.vim')
    " - multiple-cursors : multiple selections    {{{3
    call dein#add('terryma/vim-multiple-cursors')
    " bundles: encryption    {{{2
    " - gnupg : transparently edit gpg-encrypted files    {{{3
    call dein#add('jamessan/vim-gnupg')
    " bundles: searching and finding    {{{2
    " - ranger : curses-based file explorer    {{{3
    if VrcOS() !=# 'windows'
        call dein#add('francoiscabrol/ranger.vim', {
                    \ 'if' : 'executable("ranger")',
                    \ })
    endif
    " - vinegar : enhance netrw directory browser    {{{3
    call dein#add('tpope/vim-vinegar')
    "   . hide dot files
    let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
    " - visual-star-search : search for selected text    {{{3
    call dein#add('bronson/vim-visual-star-search')
    " - denite : integrated information display    {{{3
    "   . gave up loading denite on demand as the dependencies are
    "     too fragile; only works dependably if force load at start
    "   . call functions after dein#end [see unite.vim issue #330]
    let s:denite_hook_post_source = join([
                \ 'call denite#custom#source("grep", '
                \ . '"matchers", ["matcher_fuzzy"])',
                \ 'call denite#custom#source("buffer,file,file_rec", '
                \ . '"sorters", ["sorter_rank"])',
                \ ], "\n")
    call dein#add('shougo/denite.nvim', {
                \ 'depends'          : ['neoinclude.vim', 'neomru.vim'],
                \ 'hook_post_source' : s:denite_hook_post_source,
                \ })
    unlet s:denite_hook_post_source
    " - neomru : denite helper - recently used files    {{{3
    call dein#add('shougo/neomru.vim')
    " - session : denite helper - extra sources    {{{3
    call dein#add('chemzqm/denite-extra')
    " - global : denite helper - global/gtags    {{{3
    call dein#add('ozelentok/denite-gtags', {
                \ 'if' : 'executable("global") && executable("gtags")',
                \ })
    " bundles: cut and paste    {{{2
    " - highlightedyank : highlight yanked text    {{{3
    call dein#add('machakann/vim-highlightedyank')
    if exists(':shell')
        map y <Plug>(highlightedyank)
    endif
    " bundles: templates    {{{2
    " - template : file templates    {{{3
    call dein#add('hotoo/template.vim')
    " bundles: internet    {{{2
    " - vim-g : google lookup    {{{3
    call dein#add('szw/vim-g', {
                \ 'if'     : 'executable("perl")',
                \ 'on_cmd' : ['Google', 'Googlef'],
                \ })
    " - webapi : web browser API    {{{3
    call dein#add('mattn/webapi-vim', {
                \ 'lazy' : 1,
                \ })
    " - quicklink : md-specific web lookup and link inserter    {{{3
    call dein#add('christoomey/vim-quicklink', {
                \ 'on_ft'   : ['markdown', 'markdown.pandoc'],
                \ 'depends' : ['webapi-vim'],
                \ })
    " - open-browser : open uri in browser    {{{3
    call dein#add('tyru/open-browser.vim', {
                \ 'on_cmd' : ['OpenBrowser', 'OpenBrowserSearch',
                \             'OpenBrowserSmartSearch'],
                \ 'on_map' : {'n': ['<Plug>(openbrowser-smart-search)'],
                \             'v': ['<Plug>(openbrowser-smart-search)']},
                \ })
    " - whatdomain : look up top level domain    {{{3
    call dein#add('vim-scripts/whatdomain.vim', {
                \ 'on_cmd'  : ['WhatDomain'],
                \ 'on_func' : ['WhatDomain'],
                \ })
    " - w3m : console browser    {{{3
    call dein#add('yuratomo/w3m.vim', {
                \ 'if'     : 'executable("w3m")',
                \ 'on_cmd' : ['W3m',             'W3mTab',
                \             'W3mSplit',        'W3mVSplit',
                \             'W3m',             'W3mClose',
                \             'W3mCopyUrl',      'W3mReload',
                \             'W3mAddressBar',   'W3mShowExternalBrowser',
                \             'W3mSyntaxOff',    'W3mSyntaxOn',
                \             'W3mSetUserAgent', 'W3mHistory',
                \             'W3mHistoryClear'],
                \ })
    " - lbdbq : address book    {{{3
    call dein#add('vim-scripts/lbdbq', {
                \ 'on_ft' : ['mail'],
                \ })
    " bundles: printing    {{{2
    " - dn-print-dialog : pure vim print dialog    {{{3
    call dein#add('dnebauer/vim-dn-print-dialog', {
                \ 'on_cmd' :  ['PrintDialog'],
                \ })
    " bundles: calendar    {{{2
    " - calendar : display calendar    {{{3
    call dein#add('mattn/calendar-vim', {
                \ 'on_cmd' : ['Calendar', 'CalendarH', 'CalendarT'],
                \ })
    " bundles: completion    {{{2
    " - deoplete : nvim completion engine    {{{3
    "   . previously enabled at InsertEnter but is currently
    "     (nvim: 0.1.3, python-neovim: 0.1.9) failing with
    "     numerous error messages so enable at startup to make
    "     troubleshooting easier
    "   . attempting to set g:deoplete#enable_at_startup using
    "     hook_source failed for unknown reasons, so instead
    "     start plugin at VimEnter (using hook_post_source)
    "   . plugin author recommends initialising it at VimEnter
    "     and requires all configuration to be done by then
    let s:deoplete_config = join([
                \ 'call deoplete#initialize()',
                \ 'call deoplete#enable()',
                \ 'call deoplete#custom#'
                \ . 'set("_", "matchers", ["matcher_fuzzy"])',
                \ 'call deoplete#custom#'
                \ . 'set("_", "converters", ["converter_remove_paren"])',
                \ 'call deoplete#custom#'
                \ . 'set("_", "disabled_syntaxes", ["Comment", "String"])',
                \ 'call deoplete#custom#'
                \ . 'set("_", "min_pattern_length", 3)',
                \ ], "\n")
    call dein#add('shougo/deoplete.nvim', {
                \ 'if'               : 'exists(":terminal")',
                \ 'hook_post_source' : s:deoplete_config,
                \ })
    unlet s:deoplete_config
    " - neocomplete : vim completion engine    {{{3
    call dein#add('shougo/neocomplete.vim', {
                \ 'if'               : '     exists(":shell")'
                \                    . ' &&  v:version >= 704'
                \                    . ' &&  has("lua")',
                \ 'hook_post_source' :  'call neocomplete#initialize()',
                \ })
    " - neco-syntax : completion syntax helper    {{{3
    call dein#add('shougo/neco-syntax', {
                \ 'on_source' : ['neocomplete.vim', 'deoplete.nvim'],
                \ })
    " - neco-vim : completion source helper    {{{3
    call dein#add('shougo/neco-vim', {
                \ 'on_ft' : ['vim'],
                \ })
    " - echodoc : plugin helper that prints to echo area    {{{3
    let s:echodoc_hook_source = join([
                \ 'let g:echodoc_enable_at_startup = 1',
                \ 'set cmdheight=2',
                \ ], "\n")
    call dein#add('shougo/echodoc.vim', {
                \ 'on_event'    : ['CompleteDone'],
                \ 'hook_source' : s:echodoc_hook_source,
                \ })
    unlet s:echodoc_hook_source
    " - neopairs : completion helper closes paired structures    {{{3
    call dein#add('shougo/neopairs.vim', {
                \ 'on_source' : ['neocomplete.vim', 'deoplete.nvim'],
                \ 'if'        : '     v:version >= 704'
                \             . ' &&  has("patch-7.4.774")',
                \ })
    " - perlomni : perl completion    {{{3
    call dein#add('c9s/perlomni.vim', {
                \ 'if'    : 'v:version >= 702',
                \ 'on_ft' : ['perl'],
                \ })
    " - delimitMate : completion helper closes paired syntax    {{{3
    call dein#add('raimondi/delimitMate', {
                \ 'on_event' : 'InsertEnter',
                \ })
    " bundles: snippets    {{{2
    " - neonippet : snippet engine    {{{3
    call dein#add('shougo/neosnippet.vim', {
                \ 'on_event' : 'InsertCharPre',
                \ })
    " - snippets : snippet library    {{{3
    call dein#add('honza/vim-snippets', {
                \ 'on_source' : ['neosnippet.vim'],
                \ })
    " bundles: formatting    {{{2
    " - tabular : align text    {{{3
    call dein#add('godlygeek/tabular', {
                \ 'on_cmd' : ['Tabularize', 'AddTabularPattern',
                \             'AddTabularPipeline'],
                \ })
    " - splitjoin : single <-> multi-line statements    {{{3
    call dein#add('andrewradev/splitjoin.vim', {
                \ 'on_cmd' : ['SplitjoinSplit', 'SplitjoinJoin'],
                \ 'on_map' : {'n': ['gS', 'gJ']},
                \ })
    " bundles: spelling, grammar, word choice    {{{2
    " - dict : online dictionary (dict client)    {{{3
    call dein#add('szw/vim-dict', {
                \ 'on_cmd' : ['Dict'],
                \ })
    " - grammarous : grammar checker    {{{3
    call dein#add('rhysd/vim-grammarous', {
                \ 'depends' : ['unite.vim'],
                \ 'on_cmd'  : ['GrammarousCheck', 'GrammarousReset',
                \              'Unite grammarous'],
                \ })
    " - wordy : find usage problems    {{{3
    call dein#add('reedes/vim-wordy', {
                \ 'on_cmd'  : ['Wordy',     'NoWordy',
                \              'NextWordy', 'PrevWordy'],
                \ })
    " - online-thesaurus : online thesaurus    {{{3
    call dein#add('beloglazov/vim-online-thesaurus', {
                \ 'on_cmd' : ['Thesaurus', 'OnlineThesaurusCurrentWord'],
                \ })
    " - abolish : word replace and format variable names    {{{3
    call dein#add('tpope/vim-abolish', {
                \ 'on_cmd' : ['Abolish', 'Subvert'],
                \ 'on_map' : {'n': ['crc', 'crm', 'cr_', 'crs', 'cru',
                \                   'crU', 'cr-', 'crk', 'cr.']},
                \ })
    " bundles: keyboard navigation    {{{2
    " - hardmode : restrict navigation keys    {{{3
    call dein#add('wikitopian/hardmode', {
                \ 'on_func' : ['HardMode', 'EasyMode'],
                \ })
    " - matchit : jump around matched structures    {{{3
    call dein#add('vim-scripts/matchit.zip')
    " - sneak : two-character motion plugin    {{{3
    call dein#add('justinmk/vim-sneak')
    " - vim-textobj-sentence : improve sentence text object and motion    {{{3
    call dein#add('reedes/vim-textobj-sentence', {
                \ 'depends' : ['vim-textobject-user'],
                \ })
    " bundles: ui    {{{2
    " - airline : status line    {{{3
    let s:airline_hook_source = join([
                \ 'let g:airline#extensions#branch#enabled = 1',
                \ 'let g:airline#extensions#branch#empty_message = ""',
                \ 'let g:airline#extensions#branch#displayed_head_limit = 10',
                \ 'let g:airline#extensions#branch#format = 2',
                \ 'let g:airline#extensions#tagbar#enabled = 1',
                \ ], "\n")
    call dein#add('vim-airline/vim-airline', {
                \ 'if'          : 'v:version >= 702',
                \ 'hook_source' : s:airline_hook_source,
                \ })
    unlet s:airline_hook_source
    " - airline-themes : airline helper    {{{3
    call dein#add('vim-airline/vim-airline-themes', {
                \ 'depends' : ['vim-airline'],
                \ })
    " - tagbar : outline viewer    {{{3
    call dein#add('majutsushi/tagbar', {
                \ 'if'     : '     v:version >= 701'
                \          . ' &&  executable("ctags")',
                \ 'on_cmd' : ['TagbarOpen',          'TagbarClose',
                \             'TagbarToggle',        'Tagbar',
                \             'TagbarOpenAutoClose', 'TagbarTogglePause',
                \             'TagbarSetFoldLevel',  'TagbarShowTag',
                \             'TagbarCurrentTag',    'TagbarGetTypeConfig',
                \             'TagbarDebug',         'TagbarDebugEnd'],
                \ })
    " - [various] : colour schemes    {{{3
    call dein#add('atelierbram/vim-colors_atelier-schemes')  " atelier
    call dein#add('w0ng/vim-hybrid')                         " hybrid
    call dein#add('jonathanfilip/vim-lucius')                " lucius
    call dein#add('nlknguyen/papercolor-theme')              " papercolor
    call dein#add('vim-scripts/peaksea')                     " peaksea
    call dein#add('vim-scripts/print_bw.zip')                " print_bw
    call dein#add('jpo/vim-railscasts-theme')                " railscast
    call dein#add('altercation/vim-colors-solarized')        " solarized
    call dein#add('icymind/NeoSolarized')                    " neosolarized
    call dein#add('jnurmine/zenburn', {
                \ 'if' : '     v:version >= 704'
                \      . ' &&  has("patch-7.4.1826")',
                \ })                                         " zenburn
    " - terminus : enhance terminal integration    {{{3
    call dein#add('wincent/terminus', {
                \ 'if' : '!has("gui")'
                \ })
    " - numbers : number <->relativenumber switching    {{{3
    call dein#add('myusuf3/numbers.vim')
    " bundles: linting    {{{2
    " - utility functions    {{{3
    function! VrcPipInstall(pkg)    " {{{4
        if executable('pip')
            call system('pip install --upgrade ' . a:pkg)
        endif
        if executable('pip3')
            call system('pip3 install --upgrade ' . a:pkg)
        endif
    endfunction
    function! VrcNpmInstall(pkg)    " {{{4
        let l:install_pkg = 1
        if executable('npm-name')
            call system('npm-name ' . a:pkg)
            let l:install_pkg = v:shell_error
        endif
        if l:install_pkg
            call system('npm --global install ' . a:pkg)
        endif
        call system('npm --global update ' . a:pkg)
    endfunction
    function! VrcGemInstall(pkg)    " {{{4
        if executable('gem')
            call system('sudo gem install ' . a:pkg)
        endif
    endfunction
    function! VrcUpdateLinters(engines)    " {{{4
        if type(a:engines) != type([])  " script error
            echoerr 'Engines variable is not a list'
            return
        endif
        for l:engine in a:engines
            if     l:engine ==# 'autopep8'              " autopep8
                call VrcPipInstall('autopep8')
            elseif l:engine ==# 'flake8'                " flake8
                call VrcPipInstall('flake8')
            elseif l:engine ==# 'mdl'                   " mdl
                call VrcGemInstall('mdl')
            elseif l:engine ==# 'proselint'             " proselint
                call VrcPipInstall('proselint')
            elseif l:engine ==# 'remark-lint'           " remark-lint
                call VrcNpmInstall('remark-lint')
            elseif l:engine ==# 'rubocop'               " rubocop
                call VrcGemInstall('rubocop')
            elseif     l:engine ==# 'vim-vint'          " vim-vint
                call VrcPipInstall('vim-vint')
            elseif l:engine ==# 'write-good'            " write-good
                call VrcNpmInstall('write-good')
            else
                echoerr "Unknown linter keyword '" . l:engine . "'"
            endif
        endfor
    endfunction    " }}}4
    function! VrcAleLinters()    " {{{4
        call VrcUpdateLinters([
                    \ 'write-good',  'proselint', 'mdl',
                    \ 'remark-lint', 'vim-vint',  'flake8',
                    \ 'autopep8', 'rubocop',
                    \ ])
    endfunction    " }}}4
    function! VrcNeomakeLinters()    " {{{4
        call VrcUpdateLinters(['vim-vint'])
    endfunction    " }}}4
    " - ale : linter for vim/nvim    {{{3
    if VrcLinterEngine() ==# 'ale'
        call dein#add('w0rp/ale', {
                    \ 'hook_post_update' : function('VrcAleLinters'),
                    \ })
    endif
    " - neomake : linter for vim/nvim    {{{3
    if VrcLinterEngine() ==# 'neomake'
        call dein#add('neomake/neomake', {
                    \ 'hook_post_update' : function('VrcNeomakeLinters'),
                    \ })
    endif
    " - syntastic : linter for vim    {{{3
    if VrcLinterEngine() ==# 'syntastic'
        call dein#add('scrooloose/syntastic', {
                    \ 'if' : 'exists(":shell")',
                    \ })
    endif    " }}}3
    " bundles: tags    {{{2
    " - misc : plugin library used by other scripts    {{{3
    call dein#add('xolox/vim-misc', {
                \ 'if' : 'executable("ctags")',
                \ })
                " - fails in git-bash/MinTTY with error:
                "   'Failed to read temporary file...'
    " - shell : asynchronous operations in ms windows    {{{3
    call dein#add('xolox/vim-shell', {
                \ 'if' : 'executable("ctags")',
                \ })
    " - [tag generators] : decide which tag plugin to load    {{{3
    "   . prefer gen_tags over easytags unless
    "     file 'vimrc_prefer_easytags' is present
    "   . to use gen_tags, need executables 'global' and 'gtags'
    "   . to use easytags, need executable 'ctags'
    let s:prefer_easytags = resolve(expand('<sfile>:p:h'))
                \ . '/.vimrc_prefer_easytags'
    let s:added_plugin = 0
    " - gen_tags : automated tag generation    {{{3
    if !s:added_plugin && !filereadable(s:prefer_easytags) 
                \ && executable('global') && executable('gtags')
        if !executable('ctags') | let g:loaded_gentags#ctags = 1 | endif
        call dein#add('jsfaint/gen_tags.vim')
        let s:added_plugin = 1
    endif
    " - easytags : automated tag generation    {{{3
    if !s:added_plugin && executable('ctags')
        call dein#add('xolox/vim-easytags')
        let s:added_plugin = 1
    endif
    " - [tag generators] : warn user if none loaded    {{{3
    if !s:added_plugin
        echomsg 'Did not load any of these tag generation plugins:'
        echomsg '- xolox/vim-easytags'
        echomsg '- jsfaint/gen_tags.vim'
    endif
    unlet s:prefer_easytags s:added_plugin
    " bundles: version control    {{{2
    " - gitgutter : git giff symbols in gutter    {{{3
    call dein#add('airblade/vim-gitgutter', {
                \ 'if' : '    executable("git")'
                \      . '&&  ('
                \      . '      ('
                \      . '            exists(":shell")'
                \      . '        &&  v:version > 704'
                \      . '        &&  has("patch-7.4.1826")'
                \      . '      )'
                \      . '      ||'
                \      . '      exists(":terminal")'
                \      . '    )',
                \ })
    " - fugitive : git integration    {{{3
    call dein#add('tpope/vim-fugitive', {
                \ 'if' : 'executable("git")',
                \ })
    " bundles: clang support    {{{2
    call dein#add('zchee/deoplete-clang', {
                \ 'if'      : 'exists(":terminal")',
                \ 'on_ft'   : ['c', 'cpp', 'objc'],
                \ 'depends' : ['deoplete.nvim'],
                \ })
    " bundles: docbook support    {{{2
    " - snippets : docbook5 snippets    {{{3
    call dein#add('jhradilek/vim-snippets', {
                \ 'on_ft' : ['docbk'],
                \ })
    " - docbk : docbook5 support    {{{3
    call dein#add('jhradilek/vim-docbk', {
                \ 'on_ft' : ['docbk'],
                \ })
    " - dn-docbk : docbook5 support    {{{3
    call dein#add('dnebauer/vim-dn-docbk', {
                \ 'on_ft' : ['docbk'],
                \ })
    " bundles: go support    {{{2
    " - vim-go : language support    {{{3
    call dein#add('fatih/vim-go', {
                \ 'on_ft' : ['go'],
                \ })
    " - deoplete-go : deoplete helper    {{{3
    call dein#add('zchee/deoplete-go', {
                \ 'if'        : 'exists(":terminal")',
                \ 'on_source' : ['vim-go'],
                \ 'build'     : 'make',
                \ })

    " bundles: html support    {{{2
    " - html5 : html5 support    {{{3
    call dein#add('othree/html5.vim', {
                \ 'on_ft' : ['html'],
                \ })
    " - sparkup : condensed html parser    {{{3
    call dein#add('rstacruz/sparkup', {
                \ 'on_ft' : ['html'],
                \ })
    " - emmet : expand abbreviations    {{{3
    call dein#add('mattn/emmet-vim', {
                \ 'on_ft' : ['html', 'css'],
                \ })
    " bundles: java support    {{{2
    " - javacomplete2 - completion    {{{3
    call dein#add('artur-shaik/vim-javacomplete2', {
                \ 'on_ft' : ['java'],
                \ })
    " bundles: javascript support    {{{2
    " - tern + jsctags : javascript tag generator    {{{3
    " - jsctags install details    {{{4
    "   . provides tag support for javascript
    "   . is installed by npm as binaries
    "     - npm requires node.js which is no longer supported on cygwin
    "     - so cannot install jsctags on cygwin
    "   . requires tern_for_vim
    "   . is reinstalled whenever tern is updated - see tern install next
    "   . npm install command used below assumes npm is configured to
    "     install in global mode without needing superuser privileges
    " - tern install details    {{{4
    "   . is installed by npm
    "     - npm requires node.js which is no longer supported on cygwin
    "     - so cannot install tern on cygwin
    "   . npm install command used below assumes npm is configured to
    "     install in global mode without needing superuser privileges
    "   . update of tern is used as trigger to reinstall jsctags
    function! VrcBuildTernAndJsctags()                               "    {{{4
        " called by post-install hook below
        call VrcBuildTern()
        call VrcBuildJsctags()
    endfunction
    function! VrcBuildTern()                                         "    {{{4
        let l:feedback = system('npm install')
        if v:shell_error
            echoerr 'Unable to build tern-for-vim plugin'
            if strlen(l:feedback) > 0
                echoerr 'Error message: ' . l:feedback
            endif
        endif
    endfunction
    function! VrcBuildJsctags()                                      "    {{{4
        let l:cmd = 'npm install -g ' .
                    \ 'git+https://github.com/ramitos/jsctags.git'
        unlet l:feedback
        let l:feedback = system(l:cmd)
        if v:shell_error
            echoerr 'Unable to install jsctags binaries'
            if strlen(l:feedback) > 0
                echoerr 'Error message: ' . l:feedback
            endif
        endif
    endfunction
    function! VrcCygwin()                                            "    {{{4
        return system('uname -o') =~# '^Cygwin'
    endfunction
    " - install    {{{4
    "   . cannot test for cygwin in dein#add 'if' statement
    "   . doing so results in 'E48: Not allowed in sandbox
    if !VrcCygwin()
        call dein#add('ternjs/tern_for_vim', {
                    \ 'if'               : 'exists(":shell")',
                    \ 'on_ft'            : ['javascript', 'javascript.jsx'],
                    \ 'hook_post_update' : function('VrcBuildTernAndJsctags'),
                    \ })
        let s:ternjs_hook_source = join([
                    \ 'let g:tern_request_timeout = 1',
                    \ 'let g:tern_show_signature_in_pum = 0',
                    \ ], "\n")
        call dein#add('carlitux/deoplete-ternjs', {
                    \ 'if'               : 'exists(":terminal")',
                    \ 'on_ft'            : ['javascript', 'javascript.jsx'],
                    \ 'depends'          : ['deoplete.nvim'],
                    \ 'hook_source'      : s:ternjs_hook_source,
                    \ 'hook_post_update' : 'npm install -g tern',
                    \ })
        unlet s:ternjs_hook_source
    endif
    " bundles: latex support    {{{2
    " - vimtex : latex support    {{{3
    call dein#add('lervag/vimtex', {
                \ 'on_ft' : ['tex','latex'],
                \ })
    " - dn-latex : latex support    {{{3
    call dein#add('dnebauer/vim-dn-latex', {
                \ 'on_ft' : ['tex','latex'],
                \ })
    " bundles: lua support    {{{2
    " - ftplugin : lua support    {{{3
    call dein#add('xolox/vim-lua-ftplugin', {
                \ 'on_ft' : ['lua'],
                \ })
    " - manual : language support    {{{3
    call dein#add('indiefun/vim-lua-manual', {
                \ 'on_ft' : ['lua'],
                \ })
    " - lua : improved lua 5.3 syntax and indentation support    {{{3
    call dein#add('tbastos/vim-lua', {
                \ 'on_ft' : ['lua'],
                \ })
    " bundles: markdown support    {{{2
    " - markdown2ctags : tag generator    {{{3
    call dein#add('jszakmeister/markdown2ctags', {
                \ 'on_ft' : ['markdown','markdown.pandoc'],
                \ })
    " - dn-markdown : md support    {{{3
    "   . customise
    let g:DN_markdown_fontsize_print     = 12
    let g:DN_markdown_linkcolor_print    = 'blue'
    call dein#add('dnebauer/vim-dn-markdown', {
                \ 'on_ft' : ['markdown','markdown.pandoc'],
                \ })
    " - previm : realtime preview    {{{3
    call dein#add('kannokanno/previm', {
                \ 'on_ft'   : ['markdown','markdown.pandoc'],
                \ 'depends' : ['open-browser.vim'],
                \ 'on_cmd'  : ['PrevimOpen'],
                \ })
    " - toc : generate table of contents    {{{3
    call dein#add('mzlogin/vim-markdown-toc', {
                \ 'on_ft'   : ['markdown','markdown.pandoc'],
                \ 'on_cmd'  : ['GenTocGFM', 'GenTocRedcarpet',
                \              'UpdateToc', 'RemoveToc'],
                \ })
    " bundles: perl support    {{{2
    " - perl : perl support    {{{3
    call dein#add('vim-perl/vim-perl', {
                \ 'on_ft' : ['perl'],
                \ })
    " - dn-perl : perl support    {{{3
    call dein#add('dnebauer/vim-dn-perl', {
                \ 'on_ft' : ['perl'],
                \ })
    " - perlhelp : provide help with perldoc    {{{3
    call dein#add('vim-scripts/perlhelp.vim', {
                \ 'if'    : 'executable("perldoc")',
                \ 'on_ft' : ['perl'],
                \ })
    " - syntastic-perl6 : syntax hecking for perl6    {{{3
    if VrcLinterEngine() ==# 'syntastic'
        call dein#add('nxadm/syntastic-perl6', {
                    \ 'if'    : 'exists(":shell")',
                    \ 'on_ft' : ['perl6'],
                    \ })
    endif
    " - unite-perl-module : search for perl modules    {{{3
    call dein#add('yuuki/unite-perl-module.vim', {
                \ 'depends' : ['unite.vim'],
                \ 'on_ft'   : ['perl6'],
                \ })
    " bundles: php support    {{{2
    " - phpctags : tag generation    {{{3
    "   . cannot test for cygwin in dein#add 'if' statement
    "   . doing so results in 'E48: Not allowed in sandbox
    if !VrcCygwin()
        call dein#add('vim-php/tagbar-phpctags.vim', {
                    \ 'if'    : 'executable("curl")',
                    \ 'on_ft' : ['php'],
                    \ 'build' : 'make',
                    \ })
        "           build 'phpctags' executable
        "           build fails in cygwin
    endif
    " bundles: python support    {{{2
    "  - jedi : autocompletion    {{{3
    let s:jedi_hook_post_update = join([
                \ 'if executable("pip")',
                \ 'call system("pip install --upgrade jedi")',
                \ 'endif',
                \ 'if executable("pip3")',
                \ 'call system("pip3 install --upgrade jedi")',
                \ 'endif',
                \ ], "\n")
    call dein#add('davidhalter/jedi-vim', {
                \ 'if'               : 'exists(":shell")',
                \ 'on_ft'            : ['python'],
                \ 'hook_post_update' : s:jedi_hook_post_update,
                \ })
    " - deoplete-jedi : deoplete helper    {{{3
    "   . do not check for python3 in nvim (see note above at 'nvim issues')
    call dein#add('zchee/deoplete-jedi', {
                \ 'if'               : '    exists(":terminal")'
                \                    . ' && executable("python3")',
                \ 'on_ft'            : ['python'],
                \ 'depends'          : ['deoplete.nvim'],
                \ 'hook_post_update' : s:jedi_hook_post_update,
                \ })
    unlet s:jedi_hook_post_update
    " - pep8 : indentation support    {{{3
    call dein#add('hynek/vim-python-pep8-indent', {
                \ 'on_ft' : 'python',
                \ })
    " bundles: tmux support    {{{2
    " navigator : split navigation    {{{3
    call dein#add('christoomey/vim-tmux-navigator')
    " tmux : tmux.conf support    {{{3
    call dein#add('tmux-plugins/vim-tmux', {
                \ 'on_ft' : ['tmux'],
                \ })
    " bundles: vimhelp support    {{{2
    " - vimhelplint : lint for vim help    {{{3
    call dein#add('machakann/vim-vimhelplint', {
                \ 'on_ft'  : ['help'],
                \ 'on_cmd' : ['VimhelpLint'],
                \ })
    " - dn-help : custom help    {{{3
    call dein#add('dnebauer/vim-dn-help')
    " bundles: xml support    {{{2
    " - xml : xml support    {{{3
    call dein#add('vim-scripts/xml.vim', {
                \ 'on_ft' : ['xml'],
                \ })
    " bundles: xquery support    {{{2
    " - indentomnicomplete : autoindent and omnicomplete    {{{3
    call dein#add('vim-scripts/XQuery-indentomnicompleteftplugin', {
                \ 'on_ft' : ['xquery'],
                \ })
    " bundles: zsh support    {{{2
    " - deoplete-zsh : deoplete helper    {{{3
    call dein#add('zchee/deoplete-zsh', {
                \ 'on_ft' : ['zsh'],
                \ })
  " close dein    {{{2
  call dein#end()
  call dein#save_state()
endif
unlet s:dein_dir
" required settings    {{{2
filetype on
filetype plugin on
filetype indent on
syntax enable
" call post-source hooks    {{{2
augroup dein_config
    autocmd!
    autocmd VimEnter * call dein#call_hook('post_source')
augroup END
" install new bundles on startup    {{{2
if dein#check_install()
    call dein#install()
endif

" SUBSIDIARY CONFIGURATION FILES:                                    "    {{{1
call VrcSource(VrcVimPath('home').'/rc', resolve(expand('<sfile>:p')))

" FINAL CONFIGURATION:    {{{1
" set filetype to 'text' if not known    {{{2
augroup vrc_unknown_files
    autocmd!
    autocmd BufEnter *
                \ if &filetype == "" |
                \   setlocal ft=text |
                \ endif
augroup END

" set colour column    {{{2
" - placing this line in subsidiary configuration files has no effect,
"   but placed here it works
" - note: &colorcolumn was set in subsidiary config file 'align.vim'
if exists('+colorcolumn')
    highlight ColorColumn term=Reverse ctermbg=Yellow guibg=LightYellow
endif    " }}}2
" }}}1

" vim: set foldmethod=marker :
