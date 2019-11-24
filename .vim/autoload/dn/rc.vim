" Vimrc library
" Last change: 2018 Aug 12
" Maintainer: David Nebauer
" License: GPL3

" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim
" }}}1

" Script variables

" s:temp_path   - temporary file path    {{{1

""
" The file path of a temporary file. The function @function(dn#rc#temp)
" returns part or all of this variable.
if !(exists('s:temp_path') && s:temp_path !=? '')
    let s:temp_path = tempname()
endif

" s:engine      - linter engine    {{{1

""
" Name of linter engine to use.
if !exists('s:lint_engine') | let s:lint_engine = v:null | endif

" s:perl_syntax - content of vim syntax file    {{{1

""
" Content of vim syntax file providing support for modern perl features:
" * 'Readonly' and 'const' keywords, from Readonly[X] and Const::Fast modules,
"   respectively.
if !exists('s:perl_syntax')
    let s:perl_syntax = [
                \ '" Vim syntax file',
                \ '" Language: perl',
                \ '" Last change: 2018 Aug 12',
                \ '" Maintainer: David Nebauer',
                \ '" License: GPL3',
                \ '',
                \ '" const keyword (Const::Fast module)',
                \ 'syn match perlStatementConstFast '
                \ . "'\\<\\%(const\\s\\+my\\)\\>'",
                \ 'command! -nargs=+ HiLinkCF hi def link <args>',
                \ 'HiLinkCF perlStatementConstFast perlStatement',
                \ '',
                \ '" Readonly keyword (Readonly and ReadonlyX modules)',
                \ 'syn match perlStatementReadonly '
                \ . "'\\<\\%(Readonly\\s\\+my\\)\\>'",
                \ 'command! -nargs=+ HiLinkRO hi def link <args>',
                \ 'HiLinkRO perlStatementReadonly perlStatement',
                \ ]
endif

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
                \ 'autopep8',    'rubocop',
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
    call dn#rc#pipInstall('git+https://github.com/msprev/panzer',
                \         'panzer')
    call dn#rc#pipInstall('git+https://github.com/msprev/pandocinject',
                \         'pandocinject')
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
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return
    endif
    " build jsctags
    call dn#rc#npmInstall('git+https://github.com/ramitos/jsctags.git',
                \         'jsctags')
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
    let b:vrc_initial_cwd = getcwd()
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
    call denite#custom#source('grep', 'matchers',
                \             ['matcher_fuzzy'])
    call denite#custom#source('buffer,file,file_rec', 'sorters',
                \             ['sorter_rank'])
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
    let g:tern_request_timeout = 1
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

" dn#rc#createDir(path)    {{{1

""
" @public
" Attempt to create a directory {path} using perl. Return bool indicating
" whether the operation is successful.
" Will accept a relative or absolute directory {path} but relative paths are
" inherently more risky.
" If an invalid {path} is provided, i.e., non |String| variable or an
" empty string, will generate the error message:
" 'Invalid directory path provided'.
" If perl is not available will write the following |hl-WarningMsg| and exit
" as unsuccessful:
" 'Perl not available - unable to create directory path: DIR_PATH'.
" If the perl module File:Path is not available will write the following
" |hl-WarningMsg| and exit as unsuccessful:
" 'Perl module File::Path not available - unable to create directory path:
" DIR_PATH'.
" If the directory {path} already exists, exit indicating success.
" In the event of creation failure will write the following |hl-WarningMsg| to
" |message-history| and exit as unsuccessful:
" 'Unable to create directory path: DIR_PATH'.
" Any shell feedback is also written.
function dn#rc#createDir(path) abort
    " check the path argument    {{{2
    if type(a:path) != type('') || a:path ==? ''
        echoerr 'Invalid directory path provided'
    endif
    " if dir path already exists then done    {{{2
    if isdirectory(a:path) | return v:true | endif
    " need perl    {{{2
    let l:cmd = 'perl -v'
    let l:feedback = systemlist(l:cmd)
    if v:shell_error
        let l:err = [ 'Perl not available - unable to create directory path:',
                    \ '  ' . a:path]
        call dn#rc#warn(l:err)
        return v:false
    endif
    " need perl module File::Path    {{{2
    let l:cmd = 'perl -MFile::Path -e 1'
    let l:feedback = systemlist(l:cmd)
    if v:shell_error
        let l:err = [ 'Perl module File::Path not available',
                    \ 'Unable to create directory path:',
                    \ '  ' . a:path]
        call dn#rc#warn(l:err)
        return v:false
    endif
    " create directory path    {{{2
    let l:cmd =   'perl -MFile::Path -e ''use File::Path qw(make_path); '
                \ . 'make_path("' . a:path . '")'''
    let l:feedback = systemlist(l:cmd)
    if !isdirectory(a:path)
        let l:err = [ 'Unable to create directory path:',
                    \ '  ' . a:path]
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    else
        return v:true  " success
    endif    " }}}2
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

" dn#rc#exceptionError(exception)    {{{1

""
" @public
" Extracts the error message from a vim {exception}, i.e., a vim
" |exception-variable|.
function! dn#rc#exceptionError(exception) abort
    let l:matches = matchlist(a:exception,
                \             '^Vim\%((\a\+)\)\=:\(E\d\+\p\+$\)')
    return (!empty(l:matches) && !empty(l:matches[1])) ? l:matches[1]
                \                                      : a:exception
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
    " check gem installer is available
    if !executable('gem')
        let l:err = [ "Installer 'gem' is not available",
                    \ "Cannot install ruby package '" . l:name . "'"]
        call dn#rc#warn(l:err)
        return v:false
    endif
    " check gem installer can be run as sudo
    if v:shell_error
        let l:err = ["Unable to run 'gem' using 'sudo'"]
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    endif
    " if not installed, install; if installed, update
    let l:installed = systemlist('sudo gem list --local --exact ' . a:package)
    let l:operation = (empty(l:installed)) ? 'install' : 'update'
    " install/update
    let l:feedback = systemlist('sudo gem ' . l:operation . ' ' . a:package)
    if v:shell_error
        let l:err = ['Unable to ' . l:operation . ' ' . l:name . ' with gem']
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
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
            call map(l:feedback, '"  " . v:val')
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
            call map(l:feedback, '"  " . v:val')
            call extend(l:err, ['Error message:'] + l:feedback)
        endif
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:feedback = systemlist('npm --global update ' . a:package)
    if v:shell_error
        let l:err = ['Unable to update ' . l:name . ' with npm']
        if !empty(l:feedback)
            call map(l:feedback, '"  " . v:val')
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
    let l:os = dn#rc#os()
    let l:home = escape($HOME, ' ')
    if     l:os ==# 'windows' | return resolve(
                \                      expand('~/AppData/Local/panzer'))
    elseif l:os ==# 'unix'    | return l:home . '/.config/panzer'
    else                      | return l:home . '/.config/panzer'
    endif
endfunction

" dn#rc#perlContrib()    {{{1

""
" @public
" Copy the following files from the vim-perl plugin's contrib directory into
" the directory $VIMHOME/after/syntax/perl/:
" * carp.vim
" * function-parameters.vim
" * highlight-all-pragmas.vim
" * moose.vim
" * try-tiny.vim
"
" Also writes the following file to the same directory to provide syntax
" support for the Readonly keyword:
" * readonly.vim
function dn#rc#perlContrib() abort
    " variables    {{{2
    let l:contrib = dn#rc#pluginRoot('vim-perl') . '/contrib'
    let l:after = dn#rc#vimPath('home') . '/after/syntax/perl'
    if !isdirectory(l:contrib)
        let l:err = [ "Cannot find perl-vim plugin's 'contrib' directory at:",
                    \ '  ' . l:contrib]
        call dn#rc#warn(l:err)
        return v:false
    endif
    if !isdirectory(l:after) && !dn#rc#createDir(l:after)
        let l:err = [ 'Unable to move perl contrib syntax files to '
                    \ . l:after]
        call dn#rc#warn(l:err)
        return v:false
    endif
    let l:files = ['highlight-all-pragmas.vim', 'function-parameters.vim',
                \  'carp.vim', 'moose.vim', 'try-tiny.vim']
    let l:custom = l:after . '/dn-custom.vim'
    let l:errors = v:false  " flag indicting whether errors occur    }}}2
    " copy contrib syntax files    {{{2
    let l:copy_err = []
    for l:file in l:files
        " set source and target filepaths    {{{3
        let l:source = l:contrib . '/' . l:file
        let l:target = l:after . '/' . l:file
        if empty(glob(l:source))
            call extend(l:copy_err, ['Cannot find contrib file:',
                        \            '  ' . l:source])
            continue
        endif
        " read source file    {{{3
        try   | let l:content = readfile(l:source, 'b')
        catch | call extend(l:copy_err,
                    \       ['Error reading ' . l:source,
                    \        '  ' . dn#rc#exceptionError(v:exception)])
        endtry
        if empty(l:content)
            call extend(l:copy_err, ['Unable to read contrib file:',
                        \            '  ' . l:source])
            continue
        endif
        " write target file    {{{3
        if exists('l:retval') | unlet l:retval | endif
        try   | let l:retval = writefile(l:content, l:target, 'bs')
        catch | call extend(l:copy_err,
                    \       ['Error writing ' . l:target,
                    \        '  ' . dn#rc#exceptionError(v:exception)])
        endtry
        if !exists('l:retval') || l:retval == -1  " success: 0, failure: -1
            call extend(l:copy_err, ['Unable to write syntax file:',
                        \            '  ' . l:target])
            continue
        endif    " }}}3
    endfor
    let l:errors = !empty(l:copy_err)
    " write custom syntax file    {{{2
    let l:custom_err = []
    if exists('l:retval') | unlet l:retval | endif
    try   | let l:retval = writefile(s:perl_syntax, l:custom, 's')
    catch | call extend(l:custom_err,
                \       ['Error writing ' . l:custom,
                \        '  ' . dn#rc#exceptionError(v:exception)])
    endtry
    if !exists('l:retval') || l:retval == -1  " success: 0, failure: -1
        call extend(l:custom_err, ['Unable to write custom syntax file:',
                    \              '  ' . l:custom])
    endif
    if !l:errors && !empty(l:custom_err) | let l:errors = v:true | endif
    " display error messages if any    {{{2
    if l:errors  " failures occurred
        if !empty(l:copy_err)
            let l:copy_err = [
                        \ 'Failures occurred copying syntax files '
                        \ . 'from perl-vim contrib directory',
                        \ '  ' . l:contrib,
                        \ '  to local after directory ' . l:after
                        \ ]
                        \ + l:copy_err
        endif
        if !empty(l:custom_err)
            let l:custom_err = [
                        \ 'Failure writing custom syntax file to',
                        \ '  ' . l:custom
                        \ ]
                        \ + l:custom_err
        endif
        call dn#rc#warn(l:copy_err + l:custom_err)
        return v:false
    else  " success
        return v:true
    endif    " }}}2
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
            let l:err = [ "Unable to install package '" . l:name
                        \ . "' with " . l:installer]
            if !empty(l:feedback)
                call map(l:feedback, '"  " . v:val')
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
        return dn#rc#pluginsDir() . '/repos/github.com/vim-perl/vim-perl'
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
" * atelierforest (base16-atelierforest) . gui
" * atelierheath (base16-atelierheath) ... gui
" * desert (desert) ...................... gui ...... | terminal
" * hybrid (hybrid) ...................... gui ...... | terminal
" * lucius (lucius) ...................... gui ...... | terminal
" * neosolarized (neosolarized) .......... gui (dark) | terminal
" * papercolor (PaperColor) .............. gui (dark) | terminal (dark)
" * peaksea (peaksea) .................... gui (dark) | terminal
" * railscasts (railscasts) .............. gui ...... | terminal
" * solarized (solarized) ................ gui (dark) | terminal
" * zenburn (zenburn) .................... gui ...... | terminal
function! dn#rc#setColorScheme(gui, terminal) abort
    if has('gui_running')    " gui
        if     a:gui ==# 'atelierforest' | colorscheme base16-atelierforest
        elseif a:gui ==# 'atelierheath'  | colorscheme base16-atelierheath
        elseif a:gui ==# 'desert'        | colorscheme desert
        elseif a:gui ==# 'gruvbox'       | colorscheme gruvbox
            set background=dark
        elseif a:gui ==# 'hybrid'
            let g:hybrid_use_Xresources = 1
            colorscheme hybrid
        elseif a:gui ==# 'lucius'        | colorscheme lucius
            "LuciusDark|LuciusDarkHighContrast|LuciusDarkLowContrast|
            "LuciusBlack|LuciusBlackHighContrast|LuciusBlackLowContrast|
            "LuciusLight|LuciusLightLowContrast|
            "LuciusWhite|LuciusWhiteLowContrast|
            "LuciusDarkLowContrast
        elseif a:gui ==# 'neosolarized'  | colorscheme neosolarized
            set background=dark
        elseif a:gui ==# 'papercolor'
            set background=dark
            set t_Co=256
            colorscheme PaperColor
        elseif a:gui ==# 'peaksea'       | colorscheme peaksea
            set background=dark
        elseif a:gui ==# 'railscasts'    | colorscheme railscasts
        elseif a:gui ==# 'solarized'     | colorscheme solarized
            set background=dark
        elseif a:gui ==# 'zenburn'       | colorscheme zenburn
        else
            echoerr "Invalid gui colorscheme '" . a:gui . "'"
        endif
    else    " no gui, presumably terminal/console
        set t_Co=256    " improves all themes in terminals
        if     a:terminal ==# 'desert'       | colorscheme desert
        elseif a:terminal ==# 'gruvbox'      | colorscheme gruvbox
            set background=dark
        elseif a:terminal ==# 'hybrid'
            let g:hybrid_use_Xresources = 1
            colorscheme hybrid
            let g:colors_name = 'hybrid'
        elseif a:terminal ==# 'lucius'       | colorscheme lucius
            "LuciusDark|LuciusDarkHighContrast|LuciusDarkLowContrast
            "LuciusBlack|LuciusBlackHighContrast|LuciusBlackLowContrast
            "LuciusLight|LuciusLightLowContrast
            "LuciusWhite|LuciusWhiteLowContrast
            "LuciusLightLowContrast
        elseif a:terminal ==# 'neosolarized' | colorscheme neosolarized
        elseif a:terminal ==# 'papercolor'   | colorscheme PaperColor
            set background=dark
        elseif a:terminal ==# 'peaksea'      | colorscheme peaksea
        elseif a:terminal ==# 'railscasts'   | colorscheme railscasts
        elseif a:terminal ==# 'solarized'    | colorscheme solarized
        elseif a:terminal ==# 'zenburn'      | colorscheme zenburn
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
    if &spell | let l:msg .= 'ON (lang=' . &spelllang . ')'
    else      | let l:msg .= 'OFF'
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

" dn#rc#symlinkWarning()    {{{1

""
" @setting b:vrc_initial_cfp
" This variable is used by @function(dn#rc#symlinkWarning) if it is set by the
" user in their startup configuration. The variable is intended to contain the
" filepath provided by the user when opening a file. It is surprisingly
" difficult to capture as |resolve()|, and |expand()| and |fnamemodify()| with
" ':p', all resolve symlinks in filepaths. One way to do it is to expand '%'
" (|:_%|) at buffer read time. For example:
" >
"   autocmd BufNewFile,BufReadPost *
"                  \ let b:vrc_initial_cfp = simplify(expand('%'))
" <
" The 'cfp' in the variable name is derived from 'current file path'. This
" mnemonic may or may not be helpful in remembering the variable name.

""
" @setting b:vrc_initial_cwd
" This variable is used by @function(dn#rc#symlinkWarning), if present, when
" the current directory has been changed by |:lcd| or |:tcd|. It is intended
" to capture the original current directory before it was changed. For
" example, execute the following command before either |:lcd| or |:tcd|:
" >
"   let b:vrc_initial_cwd = getcwd()
" <
" The 'cwd' in the variable name is derived from 'current working directory'.
" This mnemonic may or may not be helpful in remembering the variable name.

""
" @public
" Display warning if opening a file whose path contains a symlink.
"
" This function relies on one (or two) values being captured in buffer
" variables by other parts of the startup configuration:
"
" First is the file path specified by the user on the command line, which is
" captured in 'b:vrc_initial_cfp'. This path is surprisingly difficult to
" capture as |resolve()|, and |expand()| and |fnamemodify()| with ':p', all
" resolve symlinks in filepaths. One way to do it is to expand '%' (|:_%|) at
" buffer read time. For example:
" >
"   autocmd BufNewFile,BufReadPost *
"                  \ let b:vrc_initial_cfp = simplify(expand('%'))
" <
" Second, if the current directory has been changed by |:lcd| or |:tcd| then
" the original current directory needs to be captured in 'b:vrc_initial_cwd'.
" For example:
" >
"   let b:vrc_initial_cwd = getcwd()
" <
" If either variable is missing when it is required, the function exits and
" the symlink check is aborted silently.
function! dn#rc#symlinkWarning() abort
    " only check certain buffers:
    " - buffer must be associated with a file
    if empty(bufname('%')) | return | endif
    " - must be a normal buffer (buftype == "")
    if !empty(getbufvar('%', '&buftype')) | return | endif
    " first do simple check for whether file is a symlink
    let l:file_path = fnameescape(expand('<afile>:p'))
    if getftype(l:file_path) ==# 'link'
        let l:real_path = resolve(l:file_path)
        let l:msg = []
        call add(l:msg, 'Buffer file is a symlink')
        call add(l:msg, '- file path: ' . l:file_path)
        call add(l:msg, '- real path: ' . l:real_path)
        call add(l:msg, ' ')  " so file name does not obscure last line
        call dn#rc#warn(l:msg)
        return
    endif
    " if file is not symlink, check for symlink in full file path
    " - requires b:vrc_initial_cfp
    if !exists('b:vrc_initial_cfp') | return | endif
    " - requires b:vrc_initial_cwd if current directory has been changed
    let l:file_path = ''
    if haslocaldir()
        " then initial cwd was changed with :lcd or :tcd
        " - need b:vrc_initial_cwd
        if !exists('b:vrc_initial_cwd') | return | endif
        let l:file_path = b:vrc_initial_cwd . '/' . b:vrc_initial_cfp
    else
        " initial cwd has not been altered
        let l:file_path = getcwd() . '/' . b:vrc_initial_cfp
    endif
    let l:real_path = resolve(l:file_path)
    if l:file_path !=# l:real_path
        let l:msg = []
        call add(l:msg, 'Buffer file path includes at least one symlink')
        call add(l:msg, '- file path: ' . l:file_path)
        call add(l:msg, '- real path: ' . l:real_path)
        call add(l:msg, ' ')  " so file name does not obscure last line
        call dn#rc#warn(l:msg)
    endif
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
