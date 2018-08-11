" Vimrc library
" Last change: 2018 Aug 11
" Maintainer: David Nebauer
" License: GPL3

" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim
" }}}1

" Script variables

" s:temp_path - temporary file path    {{{1

""
" The file path of a temporary file. The function @function(dn#rc#temp)
" returns part or all of this variable.
if !(exists('s:temp_path') && s:temp_path !=? '')
    let s:temp_path = tempname()
endif

" s:engine - linter engine    {{{1

""
" Name of linter engine to use.
if !exists('s:lint_engine') | let s:lint_engine = v:null | endif

" }}}1

" Public functions

" dn#rc#addThesaurus(file)    {{{1

""
" @public
" Add a 'thesaurus' {file}. Displays an error message if the thesaurus {file}
" cannot be located.
function! dn#rc#addThesaurus(file) abort
    " make sure thesaurus file exists and is readable
    if type(a:file) != type('') || a:file ==? ''
        echoerr 'Invalid thesaurus file value'
    endif
    let l:file = resolve(expand(a:file))
    if !filereadable(l:file)
        echoerr "Cannot find thesaurus file '" . a:file . "'"
    endif
    " add to thesaurus file variable (string, comma-delimited)
    if &thesaurus !=? '' | let &thesaurus .= ',' | endif
    let &thesaurus .= l:file
endfunction

" dn#rc#aleLinters()    {{{1

""
" @public
" Update ale linters:
" * autopep8    - for python
" * flake8      - for python
" * mdl         - for markdown
" * proselint   - for English prose
" * remark-lint - for markdown
" * rubocop     - for ruby
" * vim-vint    - for vimscript
" * write-good  - for English prose
function! dn#rc#aleLinters() abort
    call dn#rc#updateLinters([
                \ 'write-good',  'proselint', 'mdl',
                \ 'remark-lint', 'vim-vint',  'flake8',
                \ 'autopep8', 'rubocop',
                \ ])
endfunction

" dn#rc#buildJedi()    {{{1

""
" @public
" Install jedi python package. Jedi is an autocompletion/static analysis
" library for Python
function! dn#rc#buildJedi() abort
    call dn#rc#pipInstall('jedi')
endfunction

" dn#rc#buildPandoc()    {{{1

""
" @public
" Install panzer and pandocinject python packages to support pandoc.
function! dn#rc#buildPandoc() abort
    call dn#rc#pipInstall('git+https://github.com/msprev/panzer', 'panzer')
    call dn#rc#pipInstall('git+https://github.com/msprev/pandocinject',
                \ 'pandocinject')
endfunction

" dn#rc#buildTernAndJsctags()    {{{1

""
" @public
" The utility jsctags is a javascript tag generator. It requires tern
" ("tern_for_vim"). These utilities cannot be installed if vim is running
" under Cygwin as Cygwin does not support node.js which is used by npm, the
" installer for both jsctags and tern.
function! dn#rc#buildTernAndJsctags() abort
    " check install requirements
    " - need npm
    if !executable('npm')
        let l:err = [ "Installer 'npm' is not available:",
                    \ 'Cannot build jsctags and tern-for-vim']
        call dn#rc#warn(l:err)
        return
    endif
    " - cannot install under cygwin
    if dn#rc#cygwin()
        let l:err = [ 'Vim appears to be running under Cygwin',
                    \ "Installer 'npm' is not available under Cygwin",
                    \ 'Unable to build jsctags and tern-for-vim']
        call dn#rc#warn(l:err)
        return
    endif
    " build tern
    let l:feedback = systemlist('npm install')
    if v:shell_error
        let l:err = ['Unable to build tern-for-vim plugin']
        if !empty(l:feedback)
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
    endif
    " build jsctags
    call dn#rc#npmInstall('git+https://github.com/ramitos/jsctags.git',
                \ 'jsctags')
endfunction

" dn#rc#buildTernjs()    {{{1

""
" @public
" Install tern-for-vim plugin. Tern is a code-analysis engine for JavaScript
" intended to be used with a code editor plugin.
function! dn#rc#buildTernjs() abort
    call dn#rc#npmInstall('tern')
endfunction

" dn#rc#cdToLocalDir()    {{{1

""
" @public
" Change to local (document) directory.
function! dn#rc#cdToLocalDir() abort
    if expand('%:p') !~? '://'
        lcd %:p:h
    endif
endfunction

" dn#rc#configureDenite()    {{{1

""
" @public
" Configure the following sources in the denite plugin with
" |denite#custom#source()|:
" * grep sources to use a fuzzy matcher
" * buffer and (recursive) files sources to sort by rank
function! dn#rc#configureDenite() abort
    call denite#custom#source('grep', 'matchers', ['matcher_fuzzy'])
    call denite#custom#source('buffer,file,file_rec', 'sorters',
                \ ['sorter_rank'])
endfunction

" dn#rc#configureEchodoc()    {{{1

" @setting g:echodoc#enable_at_startup
" Set to 1 - enable echodoc plugin at startup.
" Default setting is 0 - do not enable at startup.

" @setting cmdheight
" Set 'cmdheight' to 2 to make room for echodoc plugin to display information
" in the command line area.

""
" @public
" Configure echodoc plugin to enable at startup and increase the number of
" lines for the command area ('cmdheight') to allow the plugin to display
" information.
function! dn#rc#configureEchodoc() abort
    let g:echodoc#enable_at_startup = 1
    set cmdheight=2
endfunction

" dn#rc#configureTernjs()    {{{1

" @setting g:tern_request_timeout
" Set this parameter of the tern-for-vim plugin to 1.

" @setting g:tern_show_signature_in_pum
" Set this parameter of the tern-for-vim plugin to 0.

""
" @public
" Configure the tern-for-vim plugin:
" * |g:tern_request_timeout|
" * |g:tern_show_signature_in_pum|
function! dn#rc#configureTernjs() abort
    let g:tern_request_timeout       = 1
    let g:tern_show_signature_in_pum = 0
endfunction

" dn#rc#configureWinPython()    {{{1

""
" @public
" Ensure python is correctly configured in nvim for Windows. This function
" attempts to set the |g:python_host_prog| and |g:python3_host_prog|
" variables.
" Recommended usage:
" >
"   if has('nvim') && dn#rc#os ==# 'windows'
"       call dn#rc#configureWinPython()
"   endif
" <
function! dn#rc#configureWinPython()
    let l:path = expand('$APPDATA') . '\Local\Programs\Python'
    " python2
    let l:exe = l:path . '\Python27\python.exe'
    if filereadable(l:exe) | let g:python_host_prog = l:exe | endif
    " python3
    let l:exes = [l:path . '\Python35-32\python.exe',
                \ l:path . '\Python35-64\python.exe']
    for l:exe in l:exes
        if filereadable(l:exe)
            let g:python3_host_prog = l:exe
            break
        endif
    endfor
endfunction

" dn#rc#cygwin()    {{{1

""
" @public
" Detemine whether vim is currently running under Cygwin, a Unix-like
" environment and command-line interface for Microsoft Windows. Returns a
" bool.
function! dn#rc#cygwin() abort
    if executable('uname') != 1 | return v:false | endif
    return system('uname -o') =~# '^Cygwin'
endfunction

" dn#rc#error(messages)    {{{1

""
" @public
" Display error {messages}, a |List| of |Strings| using |hl-ErrorMsg|
" highlighting and then pause till user presses Enter. Uses |:echomsg| to
" ensure messages are saved to the |message-history|. There is no return
" value.
function! dn#rc#error(messages) abort
    if type(a:messages) != type([]) | return | endif
    echohl ErrorMsg
    for l:message in a:messages | echomsg l:message | endfor
    echohl None
    return
endfunction

" dn#rc#gemInstall(package, [name])    {{{1

""
" @public
" Install a ruby {package} with gem. User can optionally provide a [short]
" name for the package (no default). The installer is run using 'sudo' so this
" must be configured appropriately in the operating system. It also means this
" may fail on non-unix systems. Returns bool indicating whether package was
" successfully installed.
function! dn#rc#gemInstall(package, ...) abort
    let l:name = (a:0 && a:1 !=? '') ? a:1 : a:package
    if !executable('gem')
        let l:err = [ "Installer 'gem' is not available",
                    \ "Cannot install ruby package '" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:feedback = systemlist('sudo gem install ' . a:package)
    if v:shell_error
        let l:err = ['Unable to install ' . l:name . ' with gem']
        if !empty(l:feedback)
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    else
        return v:true  " succeeded
    endif
endfunction

" dn#rc#hasDeinRequirements()    {{{1

""
" @public
" Checks for tools required by the dein plugin: rsync and git. Displays an
" error message if any are missing. Return a bool indicating whether all
" required tool are available.
function! dn#rc#hasDeinRequirements() abort
    let l:err = []  " use as flag and error message
    " check for required tools: rsync, git
    let l:tools = ['rsync', 'git']
    let l:missing = filter(copy(l:tools), '!executable(v:val)')
    if !empty(l:missing)
        call extend(l:err, [
                    \ 'Plugin handler dein requires: ' . join(l:tools, ', '),
                    \ 'Cannot locate: ' . join(l:missing, ', ')])
    endif
    " check for required version: >= 7.4
    let l:version = v:version
    if l:version < 704
        call extend(l:err, [
                    \ 'This instance of vim is version' . l:version,
                    \ 'Plugin handler dein requires vim 7.4 or higher'])
    endif
    " return result and report any errors if detected
    if empty(l:err)  " all checks succeeded
        return v:true
    else  " errors detected
        call extend(l:err, ['Aborting vim configuration file execution'])
        call dn#rc#warn(l:err)
        return v:false
    endif
endfunction

" dn#rc#installDein()    {{{1

""
" @public
" Install dein plugin manager. Prints feedback and returns a boolean
" indicating whether installation was successful.
function! dn#rc#installDein() abort
    let l:cmd =   'git clone https://github.com/shougo/dein.vim '
                \ . dn#rc#pluginRoot('dein')
    let l:feedback = systemlist(l:cmd)
    if !v:shell_error  " succeeded
        return v:true
    else  " failed
        let l:err = 'Unable to install dein plugin manager using git'
        if !empty(l:feedback)
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#error(l:err)
        return v:false
    endif
endfunction

" dn#rc#lintEngine()    {{{1

""
" @public
" Return the linter engine to use. Calls function
" @function(dn#rc#setLintEngine) if the linter engine has not been set.
function! dn#rc#lintEngine() abort
    if s:lint_engine is v:null | call dn#rc#setLintEngine() | endif
    return s:lint_engine
endfunction

" dn#rc#message(message, [clear])    {{{1

""
" @public
" Display a |String| {message} in the command line. If [clear] is present and
" true, the message is cleared after a brief delay.
function! dn#rc#message(message, ...) abort
	let l:insert = (mode() ==# 'i')
	if mode() ==# 'i' | execute "normal \<Esc>" | endif
	echohl ModeMsg | echo a:message | echohl Normal
    if a:0 > 0 && a:1 | sleep 1 | execute "normal :\<BS>" | endif
    if l:insert | execute 'normal! l' | startinsert | endif
endfunction

" dn#rc#neomakeLinters()    {{{1

""
" @public
" Update neomake linters:
" * vim-vint - for vimscript
function! dn#rc#neomakeLinters() abort
    call dn#rc#updateLinters(['vim-vint'])
endfunction

" dn#rc#npmInstall(package, [short])    {{{1

""
" @public
"
" Install a node {package} with npm. User can optionally provide a [short]
" name for the package (no default). Packages are installed in global mode.
"
" npm requires node.js which is no longer supported on Cygwin, so if vim is
" running under Cygwin display error and abort install attempt.
" 
" Returns bool indicating whether package was successfully installed.
function! dn#rc#npmInstall(package, ...) abort
    let l:retval = 0
    let l:name = (a:0 && a:1 !=? '') ? a:1 : a:package
    if dn#rc#cygwin()  " cannot install under Cygwin
        let l:err = [ 'Vim appears to be running under Cygwin',
                    \ "Installer 'npm' requires 'node.js', which is not "
                    \ . ' supported on Cygwin',
                    \ "Unable to install package'" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    if !executable('npm')  " must have npm
        let l:err = [ "Installer 'npm' is not available",
                    \ "Cannot install node package '" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:feedback = systemlist('npm --global install ' . a:package)
    if v:shell_error
        let l:err = ['Unable to install ' . l:name . ' with npm']
        if !empty(l:feedback)
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:feedback = systemlist('npm --global update ' . a:package)
    if v:shell_error
        let l:err = ['Unable to update ' . l:name . ' with npm']
        if !empty(l:feedback)
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    else
        return v:true  " succeeded
    endif
endfunction
" dn#rc#os()    {{{1

""
" @public
" Determine operating system. Returns |String| value "windows", "unix" or
" "other".
function! dn#rc#os() abort
    if has('win32') || has ('win64') || has('win95') || has('win32unix')
        return 'windows'
    elseif has('unix') | return 'unix'
    else               | return 'other'
    endif
endfunction

" dn#rc#pandocOpen(file)    {{{1

""
" @public
" A function used by pandoc to open a created output file. See
" |g:pandoc#command#custom_open| for further details.
function! dn#rc#pandocOpen(file) abort
    return 'xdg-open ' . shellescape(expand(a:file,':p'))
endfunction

" dn#rc#panzerPath()    {{{1

""
" @public
" Provide path to panzer support directory.
function! dn#rc#panzerPath() abort
    let l:os   = dn#rc#os()
    let l:home = escape($HOME, ' ')
    if     l:os ==# 'windows'
        return resolve(expand('~/AppData/Local/panzer'))
    elseif l:os ==# 'unix'
        return l:home . '/.config/panzer'
    else
        return l:home . '/.config/panzer'
    endif
endfunction

" dn#rc#pipInstall(package, [short])    {{{1

""
" @public
" Install a python {package} with pip. User can optionally provide a [short]
" name for the package (no default). Returns bool indicating whether package
" was successfully installed.
function! dn#rc#pipInstall(package, ...) abort
    let l:name = (a:0 && a:1 !=? '') ? a:1 : a:package
    let l:installers = ['pip3', 'pip']
    let l:installer_available = v:false
    for l:installer in l:installers
        if executable(l:installer)
            let l:installer_available = v:true
        endif
    endfor
    if !l:installer_available
        let l:err = [ 'No python installers (' . join(l:installers, ', ')
                    \ . ') available',
                    \ 'Cannot install python package ' . l:name]
        call dn#rc#warn(l:err)
        return v:false
    endif
    for l:installer in l:installers
        if !executable(l:installer) | continue | endif
        let l:install_cmd = l:installer . ' install --upgrade ' . a:package
        let l:feedback = systemlist(l:install_cmd)
        if v:shell_error
            let l:err = [  "Unable to install package '" . l:name
                        \  . "' with " . l:installer]
            if !empty(l:feedback)
                call extend(l:err, ['Error message:'] + l:feedback)
            endif
            call dn#rc#warn(l:err)
            return v:false
        else
            return v:true  " succeeded
        endif
    endfor
endfunction

" dn#rc#pluginRoot(plugin)    {{{1

""
" @public
" Provide root directory of named {plugin}. The {plugin} names currently
" supported are:
" * "dein" or "dein.vim"
" * "dn-perl" or "vim-dn-perl"
" * "vim-perl"
function! dn#rc#pluginRoot(plugin) abort
    if type(a:plugin) != type('')
        echoerr 'Plugin name is not a string'
    endif
    if     count(['dein', 'dein.vim'], a:plugin)
        return dn#rc#pluginsDir() . '/repos/github.com/shougo/dein.vim'
    elseif count(['dn-perl', 'vim-dn-perl'], a:plugin)
        return  '/repos/github.com/dnebauer/vim-dn-perl'
    elseif count(['vim-perl'], a:plugin)
        return dn#ec#pluginsDir() . '/repos/github.com/vim-perl/vim-perl'
    else
        echoerr "Invalid plugin name '" . a:plugin . "'"
    endif
endfunction

" dn#rc#pluginsDir()    {{{1

""
" @public
" Provide plugins directory.
function! dn#rc#pluginsDir() abort
    return dn#rc#vimPath('plug')
endfunction

" dn#rc#saveOnFocusLost()    {{{1

""
" @public
" This function is designed to be called by an |:autocmd| when the |FocusLost|
" event occurs. For example:
" >
"   autocmd FocusLost * call dn#rc#saveOnFocusLost()
" <
" Attempting to write a buffer that is not associated with a file causes vim
" error |E141|. This function catches and ignores that error.
function! dn#rc#saveOnFocusLost() abort
    " E141 = no file name for buffer
    try
        :wall
    catch /^Vim\((\a\+)\)\=:E141:/ |
    endtry
endfunction

" dn#rc#setColorScheme(gui, terminal)    {{{1

""
" @public
" Set colour scheme. A colour scheme is nominated for {gui} versions of vim,
" e.g., gvim, and {terminal} versions of vim. In the following list the
" argument value is followed by the colorscheme name in brackets, then
" argument(s) the value can be used for, plus the 'background' setting used,
" if any.
"
" For example, "papercolor (PaperColor) - gui (dark), terminal (dark)" means
" that "papercolor" is a valid argument for both {gui} and {terminal}
" arguments, the colorscheme that is set is "PaperColor", and the 'background'
" is set to "dark" in both gui and terminal versions of vim.
" values for these arguments includes in brackets the associddated colorscheme
"
" * solarized (solarized) - gui (dark), terminal
" * neosolarized (neosolarized) - gui (dark), terminal
" * peaksea (peaksea) - gui (dark), terminal
" * desert (desert) - gui, terminal
" * hybrid (hybrid) - gui, terminal
" * railscasts (railscasts) - gui, terminal
" * zenburn (zenburn) - gui, terminal
" * lucius (lucius) - gui, terminal
" * atelierheath (base16-atelierheath) - gui
" * atelierforest (base16-atelierforest) - gui
" * papercolor (PaperColor) - gui (dark), terminal (dark)
function! dn#rc#setColorScheme(gui, terminal) abort
    if has('gui_running')    " gui
        if     a:gui ==# 'solarized'
            set background=dark
            colorscheme solarized
        elseif a:gui ==# 'neosolarized'
            set background=dark
            colorscheme neosolarized
        elseif a:gui ==# 'peaksea'
            set background=dark
            colorscheme peaksea
        elseif a:gui ==# 'desert'
            colorscheme desert
        elseif a:gui ==# 'hybrid'
            let g:hybrid_use_Xresources = 1
            colorscheme hybrid
        elseif a:gui ==# 'railscasts'
            colorscheme railscasts
        elseif a:gui ==# 'zenburn'
            colorscheme zenburn
        elseif a:gui ==# 'lucius'
            colorscheme lucius
            "LuciusDark|LuciusDarkHighContrast|LuciusDarkLowContrast|
            "LuciusBlack|LuciusBlackHighContrast|LuciusBlackLowContrast|
            "LuciusLight|LuciusLightLowContrast|
            "LuciusWhite|LuciusWhiteLowContrast|
            "LuciusDarkLowContrast
        elseif a:gui ==# 'atelierheath'
            colorscheme base16-atelierheath
        elseif a:gui ==# 'atelierforest'
            colorscheme base16-atelierforest
        elseif a:gui ==# 'papercolor'
            set background=dark
            set t_Co=256
            colorscheme PaperColor
        else
            echoerr "Invalid gui colorscheme '" . a:gui . "'"
        endif
    else    " no gui, presumably terminal/console
        set t_Co=256    " improves all themes in terminals
        if     a:terminal ==# 'solarized'
            colorscheme solarized
        elseif a:terminal ==# 'neosolarized'
            colorscheme neosolarized
        elseif a:terminal ==# 'peaksea'
            colorscheme peaksea
        elseif a:terminal ==# 'desert'
            colorscheme desert
        elseif a:terminal ==# 'hybrid'
            let g:hybrid_use_Xresources = 1
            colorscheme hybrid
            let g:colors_name = 'hybrid'
        elseif a:terminal ==# 'railscasts'
            colorscheme railscasts
        elseif a:terminal ==# 'zenburn'
            colorscheme zenburn
        elseif a:terminal ==# 'lucius'
            colorscheme lucius
            "LuciusDark|LuciusDarkHighContrast|LuciusDarkLowContrast
            "LuciusBlack|LuciusBlackHighContrast|LuciusBlackLowContrast
            "LuciusLight|LuciusLightLowContrast
            "LuciusWhite|LuciusWhiteLowContrast
            LuciusLightLowContrast
        elseif a:terminal ==# 'papercolor'
            set background=dark
            colorscheme PaperColor
        else
            echoerr "Invalid terminal colorscheme '" . a:terminal . "'"
        endif
    endif
endfunction

" dn#rc#setLintEngine([engine])    {{{1

""
" @public
" Sets linter engine to use. The linter [engine] can optionally be provided.
" Valid values are:
" * ale
" * syntastic
" * neomake
" @default engine='ale'
"
" The provided, or default, engine will be overridden in the following
" circumstances (and the user notified):
" * cannot run syntastic in nvim, so in nvim switch syntastic to "neomake"
" * for docbk files use "syntastic" (ftplugin defines custom linters)
function! dn#rc#setLintEngine(...) abort
    let l:override = v:false  " flag that choice was overridden
    let l:messages = []  " user feedback
    let l:default_engine = 'ale'  " make sure is in l:valid_engines
    let l:valid_engines = ['ale', 'syntastic', 'neomake']
    if !count(l:valid_engines, l:default_engine)  " default is not valid!
        call dn#rc#error([
                    \ 'Valid engines (' . join(l:valid_engines, ', ') . ')',
                    \ 'do not include default (' . l:default_engine . ')'
                    \ ])
        return
    endif
    if a:0 && a:1 !=? ''  " set to user value or default
        let l:engine = a:1
        call add(l:messages, "User set linter engine to '" . l:engine . "'")
    else
        let l:engine = l:default_engine
        call add(l:messages, "Linter engine defaulted to '" . l:engine . "'")
    endif
    if !count(l:valid_engines, l:engine)  " check validity
        call extend(l:messages, [
                    \ "Linter engine '" . l:engine . "' is not valid",
                    \ "(must be one of '" . join(l:valid_engines, '|') . "')",
                    \ "Setting to default: '" . l:default_engine . "'"
                    \ ])
        let l:override = v:true
        let l:engine = l:default_engine
    endif
    " overridden in specific circumstances
    " - can't use syntastic in nvim
    if l:engine ==# 'syntastic' && has('nvim')
        call extend(l:messages, [
                    \ 'Running nvim but syntastic requires vim',
                    \ "Switching to use 'neomake' instead"
                    \ ])
        let l:override = v:true
        let l:engine = 'neomake'
    endif
    " - docbk requires syntastic (ftplugin defines custom syntastic linters)
    if &filetype ==# 'docbk' && l:engine !=# 'syntastic'
        call extend(l:messages, [
                    \ 'Ftplugin dn-docbk requires the syntastic linter',
                    \ "Switching to use 'syntastic' instead"
                    \ ])
        let l:override = v:true
        let l:engine = 'neomake'
    endif
    " provide feedback if overrode linter engine
    if l:override | call dn#rc#warn(l:messages) | endif
    " set linter engine
    let s:lint_engine = l:engine
endfunction

" dn#rc#source(directory, self)    {{{1

""
" @public
" Recursively source vim files in {directory}. {self} is the resolved filepath
" of the calling script. This is an example:
" >
"   let s:dir = dn#rc#vimPath('home').'/rc'
"   call dn#rc#source(s:dir, resolve(expand('<sfile>:p')))
" <
" Prints error message and returns if {directory} path is invalid. Only
" sources vim files, more specifically, if running vim source *.vim files and
" if running nvim source *.vim and *.nvim files.
function! dn#rc#source(dir, self) abort
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
        let l:match = !has('nvim') ? '^\p\+\.vim$' : '^\p\+\.n\?vim$'
        if fnamemodify(l:path, ':t') =~? l:match
            execute 'source' l:path
        endif
    endfor
    return
endfunction

" dn#rc#spellStatus()    {{{1

""
" @public
" Display spell check status.
function! dn#rc#spellStatus() abort
    let l:msg = 'spell checking is '
    if &spell
        let l:msg .= 'ON (lang=' . &spelllang . ')'
    else
        let l:msg .= 'OFF'
    endif
    call dn#rc#message(l:msg, 1)
endfunction

" dn#rc#spellToggle()    {{{1

""
" @public
" Toggle spell checking and display new status.
function! dn#rc#spellToggle() abort
    setlocal spell!
    redraw
    call dn#rc#spellStatus()
endfunction

" dn#rc#tagPlugin(directory)    {{{1

""
" @public
" Returns the tag plugin to load: either "gen_tags" or "easytags" (or |v:null|
" if neither is usable). Plugin "gen_tags" requires executables "global" and
" "gtags", while plugin "easytags" requires executable "ctags". Plugin
" "gen_tags" is preferred over "easytags" if both are usable. This preference
" order is reversed, i.e., plugin "easytags" is preferred over "gen_tags", if
" the file "vimrc_prefer_easytags" is present in {directory}.
" An example of calling this function is:
" > 
"   if dn#rc#tagPlugin('<sfile>:p:h') ==# 'easytags' | ...
" <
function! dn#rc#tagPlugin(directory) abort
    let l:prefer_easytags_file = a:directory . '/.vimrc_prefer_easytags'
    let l:prefer_easytags = !empty(glob(l:prefer_easytags_file))
    let l:usable = {'gen_tags': executable('global') && executable('gtags'),
                \   'easytags': executable('ctags')}
    " satisfy easytags preference if possible...
    if l:prefer_easytags && l:usable.easytags | return 'easytags' | endif
    " ...otherwise use standard preference
    if     l:usable.gen_tags | return 'gen_tags'
    elseif l:usable.easytags | return 'easytags'
    else                     | return v:null
    endif
endfunction

" dn#rc#temp(part)    {{{1

""
" @public
" Sets a temporary file variable "s:temp_path" if not already set. Returns a
" {part} of the file path stored in the variable. {part} can be:
" * "path" - directory path + file name
" * "dir"  - directory path only
" * "file" - file name only
function! dn#rc#temp(part) abort
    if     a:part ==# 'path' | return s:temp_path
    elseif a:part ==# 'dir'  | return fnamemodify(s:temp_path, ':p:h')
    elseif a:part ==# 'file' | return fnamemodify(s:temp_path, ':p:t')
    else
        echoerr "Invalid dn#rc#temp param '" . a:part . "'"
    endif
endfunction

" dn#rc#updateLinters(engines)    {{{1

""
" @public
" Update a |List| of linter {engines}. Valid engine names are:
" * autopep8    - for python
" * flake8      - for python
" * mdl         - for markdown
" * proselint   - for English prose
" * remark-lint - for markdown
" * rubocop     - for ruby
" * vim-vint    - for vimscript
" * write-good  - for English prose
function! dn#rc#updateLinters(engines) abort
    if type(a:engines) != type([])  " script error
        echoerr 'Engines variable is not a list'
    endif
    for l:engine in a:engines
        if     l:engine ==# 'autopep8'              " autopep8
            call dn#rc#pipInstall('autopep8')
        elseif l:engine ==# 'flake8'                " flake8
            call dn#rc#pipInstall('flake8')
        elseif l:engine ==# 'mdl'                   " mdl
            call dn#rc#gemInstall('mdl')
        elseif l:engine ==# 'proselint'             " proselint
            call dn#rc#pipInstall('proselint')
        elseif l:engine ==# 'remark-lint'           " remark-lint
            call dn#rc#npmInstall('remark-lint')
        elseif l:engine ==# 'rubocop'               " rubocop
            call dn#rc#gemInstall('rubocop')
        elseif l:engine ==# 'vim-vint'              " vim-vint
            call dn#rc#pipInstall('vim-vint')
        elseif l:engine ==# 'write-good'            " write-good
            call dn#rc#npmInstall('write-good')
        else
            echoerr "Unknown linter keyword '" . l:engine . "'"
        endif
    endfor
endfunction

" dn#rc#vimPath(type)    {{{1

""
" @public
" Provides vim-related paths. The |String| path {type} to be returned can be
" "home", "plug" or "panzer".
function! dn#rc#vimPath(type) abort
    " vim home directory
    let l:os = dn#rc#os()
    if     a:type ==# 'home'
        let l:home = escape($HOME, ' ')
        if     l:os ==# 'windows'
            if has('nvim')  " nvim
                return resolve(expand('~/AppData/Local/nvim'))
            else  " vim
                return l:home . '/vimfiles'
            endif
        elseif l:os ==# 'unix'
            return l:home . '/.vim'
        else
            return l:home . '/.vim'
        endif
    " dein plugin directory root
    elseif a:type ==# 'plug'
        return resolve(expand('~/.cache/dein'))
    " panzer support directory
    elseif a:type ==# 'panzer'
        let l:home = escape($HOME, ' ')
        if     l:os ==# 'windows'
            return resolve(expand('~/AppData/Local/panzer'))
        elseif l:os ==# 'unix'
            return l:home . '/.config/panzer'
        else
            return l:home . '/.config/panzer'
        endif
    " error
    else
        echoerr "Invalid path type '" . a:type . "'"
    endif
endfunction

" dn#rc#vimprocBuild()    {{{1

""
" @public
" Provide the build command for the shougo/vimproc plugin. Returns a |String|
" build command.
function! dn#rc#vimprocBuild() abort
    let l:cmd = 'make'
    if executable('mingw32-make')
                \ && ( has('win64') || has('win32') || has('win32unix') )
        let s:cmd = 'mingw32-make -f ' . (
                    \ has('win64')     ? 'make_mingw64.mak'                :
                    \ has('win32')     ? 'make_mingw32.mak'                :
                    \ has('win32unix') ? 'make_mingw32.mak CC=mingw32-gcc' :
                    \ '' )
    endif
    return l:cmd
endfunction

" dn#rc#warn(messages)    {{{1

""
" @public
" Display warning {messages}, a |List| of |Strings| using |hl-WarningMsg|
" highlighting and then pause until user presses Enter. Uses |:echomsg| to
" ensure messages are saved to the |message-history|. There is no return
" value.
function! dn#rc#warn(messages) abort
    if type(a:messages) != type([]) | return | endif
    echohl WarningMsg
    for l:message in a:messages | echomsg l:message | endfor
    echohl None
    return
endfunction

" }}}1

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: foldmethod=marker :
