" Function:    Vim perl filetype plugin
" Last Change: 2015-05-03
" Maintainer:  David Nebauer <david@nebauer.org>

" ========================================================================

" CONTROL STATEMENTS                                                  {{{1

" Only do this when not done yet for this buffer                      {{{2
if exists('b:did_dn_perlsettings')
  finish
endif
let b:did_dn_perlsettings = 1

" Use default cpoptions to avoid unpleasantness from customised
" 'compatible' settings
let s:save_cpo = &cpoptions
set cpoptions&vim

" ========================================================================

" VARIABLES                                                          {{{1

" Boolean values                                                     {{{2
let b:dn_true  = 1
let b:dn_false = 0

" =======================================================================

" SETTINGS                                                           {{{1

" syntax                                                             {{{2
" include pod.vim syntax file with perl.vim
let g:perl_include_pod    = 1
" highlight complex expressions such as @{[$x, $y]}
let g:perl_extended_vars  = 1
" use more context for highlighting
let g:perl_sync_dist      = 250
" prevent error highlighting of method arguments
let g:perl_sub_signatures = b:dn_true                              " }}}2
" K help                                                             {{{2
" - default = 'perldoc -f TERM'
" - look in function, variable, general and faq help
set keywordprg=f(){\ \
            \ \ \ \ perldoc\ -f\ $*\ \
            \ \|\|\ perldoc\ -v\ $*\ \
            \ \|\|\ perldoc\ \ \ $*\ \
            \ \|\|\ perldoc\ -q\ $*\ \
            \ ;\ }\ ;\ f

" =======================================================================

" FUNCTIONS                                                          {{{1

" Function:   s:has_utils                                            {{{2
" Purpose:    checks for ftplugin dn-utils
" Parameters: nil
" Prints:     nil
" Return:     boolean
" Note:       relies on detecting function 'dn#util#error'
function! s:has_utils()
    return exists('*dn#util#error')
endfunction
" ------------------------------------------------------------------------
" Function:   s:severity_verb                                        {{{2
" Purpose:    provides verb for severity level
" Parameters: 1 - severity level (int, required)
" Prints:     nil
" Return:     string
function! s:severity_verb(level)
    let l:verbs = {5: 'Gentle', 4: 'Stern',
                \ 3: 'Harsh', 2: 'Cruel', 1: 'Brutal'}
    return l:verbs[a:level]
endfunction
" ------------------------------------------------------------------------
" Function:   s:severity_completion                                  {{{2
" Purpose:    list severity values for command completion
" Parameters: 1 - leading part of argument currently being completed
"             2 - entire command line
"             3 - cursor position in command line
" Prints:     nil
" Return:     list
function! s:severity_completion(arg, line, pos)
    return [5, 4, 3, 2, 1]
endfunction
" ------------------------------------------------------------------------
" Function:   s:param                                                {{{2
" Purpose:    extract parameter value from parameter hash
" Parameters: 1 - param hash
"             2 - param
" Prints:     errors
" Return:     parameter
function! s:param(params, param)
    " valid values
    let l:valid_values = {
                \ 'mode':     ['normal', 'insert'],
                \ 'severity': [5, 4, 3, 2, 1],
                \ }
    " check params
    if type(a:params) != type({})
        call dn#util#error('Parameter variable is NOT a dictionary')
        return
    endif
    " check param
    if a:param ==? ''
        call dn#util#error('No parameter name supplied to s:param')
        return
    endif
    " deal with invalid parameter
    if !has_key(a:params, a:param)
        call dn#util#error("Invalid parameter'" . a:param . "'")
        return
    endif
    " check validity
    let l:value = a:params[a:param]
    if !count(l:valid_values[a:param], l:value)
        let l:msg = "parameter '" . a:param . "' "
                    \ "has invalid value '" . l:value . "'"
        call dn#util#error(l:msg)
    endif
    " return parameter value (even if invalid)
    return l:value
endfunction
" ------------------------------------------------------------------------
" Function:   DNP_PerlTidy                                            {{{2
" Purpose:    run dn-perltidy on file
" Parameters: 1 - param hash
"                 mode: calling mode ('normal'|'insert')
" Prints:     feedback from dn-perltidy
" Return:     nil
function! DNP_PerlTidy(params)
    " rely on dn-utils
    if !s:has_utils()
        call dn#util#error('Cannot find dn-utils ftplugin')
        return
    endif
	" variable
    let l:mode_param_name = 'mode'
    " give feedback because reporting delayed till after tidying
    redraw | echo 'Tidying...'
	" make sure we have plugin-specific perltidy utility
    let l:tidy = dn#util#getRtpFile('vim-dn-perl-util-perltidy')
    if l:tidy ==? ''
        call dn#util#error('dn-utils: cannot find plugin perltidy utility')
        return ''
    endif
    " process variables
    let l:mode = s:param(a:params, l:mode_param_name)
    if l:mode ==? '' | return | endif
	" change to filedir if it isn't cwd
    let l:file = expand('%')
	let l:path = dn#util#getFileDir()
	let l:cwd = getcwd() . '/'
	if l:cwd !=# l:path
		try
			silent execute 'lcd' l:path
		catch
			let l:msg = 'Fatal error: Unable to change to the current' .
                        \ "document's directory:\n"
                        \ . "'" . l:path . "'.\n"
                        \ . 'Aborting.'
			call dn#util#error(l:msg)
            if l:mode ==# 'insert'
                call dn#util#insertMode(b:dn_true)
            endif
			return
		endtry
	endif
    " save file to be sure we operate on current version of it
    silent execute 'update'
    " time to tidy
    " - use of shellescape on l:cmd causes failure with command string
    "   wrapped in single quotes and interpreted as a single command
    let l:cmd = l:tidy . ' ' . l:file
    silent let l:output = systemlist(l:cmd)
    " must reload file to display changes to underlying *file*
    " redraw is required otherwise refresh occurs after list output
    silent! execute 'edit'
    redraw
    if type(l:output) == type('')  " error
        let l:msg = "Command '" . l:cmd . "' failed"
        call dn#util#error(l:msg)
        let l:msg = "Shell feedback: '" . l:output . "'"
        call dn#util#error(l:msg)
    else  " assume succeeded so have a List
        for l:item in l:output
            echo l:item
        endfor
        echo 'Tidying done'
    endif
    " do not check for v:shell_error because dn-perltidy always exits
    " with an error code - see dn-perltidy man page for details
    if l:mode ==# 'insert' | call dn#util#insertMode(b:dn_true) | endif
endfunction
" ------------------------------------------------------------------------
" Function:   DNP_PerlCritic                                          {{{2
" Purpose:    run dn-perlcritic on file
" Parameters: 1 - param hash
"                 mode:     calling mode ('normal'|'insert')
"                 severity: level of analysis (1, 2, 3, 4 or 5)
" Prints:     feedback from dn-perlcritic
" Return:     nil
function! DNP_PerlCritic(params)
    " rely on dn-utils
    if !s:has_utils()
        call dn#util#error('Cannot find dn-utils ftplugin')
        return
    endif
	" variable
    let l:mode_param_name = 'mode'
    let l:severity_param_name = 'severity'
	" make sure we have plugin-specific perltidy utility
    let l:critic = dn#util#getRtpFile('vim-dn-perl-util-perlcritic')
    if l:critic ==? ''
        call dn#util#error('dn-utils: cannot find plugin perlcritic utility')
        return ''
    endif
    " process variables
    let l:mode = s:param(a:params, l:mode_param_name)
    if l:mode ==? '' | return | endif
    let l:severity = s:param(a:params, l:severity_param_name)
    if !l:severity | return | endif
    " give feedback because reporting delayed till after analysis
    let l:msg = s:severity_verb(l:severity)
                \ . ' critique (severity ' . l:severity . ')... '
    redraw | echo l:msg
	" change to filedir if it isn't cwd
    let l:file = expand('%')
	let l:path = dn#util#getFileDir()
	let l:cwd = getcwd() . '/'
	if l:cwd !=# l:path
		try
			silent execute 'lcd' l:path
		catch
            echon 'error!'
			let l:msg = 'Fatal error: Unable to change to the current' .
                        \ "document's directory:\n"
                        \ . "'" . l:path . "'.\n"
                        \ . 'Aborting.'
			call dn#util#error(l:msg)
            if l:mode ==# 'insert'
                call dn#util#insertMode(b:dn_true)
            endif
			return
		endtry
	endif
    " save file to be sure we operate on current version of it
    silent execute 'update'
    " time to criticise
    " - use of shellescape on l:cmd causes failure with command string
    "   wrapped in single quotes and interpreted as a single command
    let l:cmd = l:critic . ' ' . l:file . ' --severity ' . l:severity
    silent let l:output = systemlist(l:cmd)
    if type(l:output) == type('')  " error
        echon 'error!'
        let l:msg = "Command '" . l:cmd . "' failed"
        call dn#util#error(l:msg)
        let l:msg = "Shell feedback: '" . l:output . "'"
        call dn#util#error(l:msg)
    elseif type(l:output) == type([])  " succeeded
        if empty(l:output)    " nothing to report
            echon 'no policy violations'
        else    " display feedback
            echon 'found policy violations:'
            for l:item in l:output
                echo l:item
            endfor
        endif
    else    " unexpected data type
        echon 'error!'
        call dn#util#error('Unexpected data type for perlcritic feedback')
        return
    endif
    " do not check for v:shell_error because perlcritic has
    " previously exited with this error even when successful:
    " 'Tests were run but no plan was declared
    "  and done_testing() was not seen.'
    if l:mode ==# 'insert' | call dn#util#insertMode(b:dn_true) | endif
endfunction

" ========================================================================

" CONTROL STATEMENTS                                                  {{{1

" restore user's cpoptions
let &cpoptions = s:save_cpo

" ========================================================================

" MAPPINGS AND COMMANDS                                               {{{1

" Mappings:                                                           {{{2

" \t -> perltidy                                                      {{{3
if !hasmapto( '<Plug>DnPTI' )
	imap <buffer> <unique> <LocalLeader>t <Plug>DnPTI
endif
imap <buffer> <unique> <Plug>DnPTI <Esc>:call DNP_PerlTidy({'mode': 'insert'})<CR>
if !hasmapto( '<Plug>DnPTN' )
	nmap <buffer> <unique> <LocalLeader>t <Plug>DnPTN
endif
nmap <buffer> <unique> <Plug>DnPTN :call DNP_PerlTidy({'mode': 'normal'})<CR>

" \cX -> perlcritic (X=1,2,3,4 or 5)                                  {{{3
" c5 = gentle
if !hasmapto( '<Plug>DnC5I' )
	imap <buffer> <unique> <LocalLeader>c5 <Plug>DnC5I
endif
imap <buffer> <unique> <Plug>DnC5I <Esc>:call DNP_PerlCritic({'mode': 'insert', 'severity': 5})<CR>
if !hasmapto( '<Plug>DnT5N' )
	nmap <buffer> <unique> <LocalLeader>c5 <Plug>DnT5N
endif
nmap <buffer> <unique> <Plug>DnT5N :call DNP_PerlCritic({'mode': 'normal', 'severity': 5})<CR>

" c4 = stern
if !hasmapto( '<Plug>DnC4I' )
	imap <buffer> <unique> <LocalLeader>c4 <Plug>DnC4I
endif
imap <buffer> <unique> <Plug>DnC4I <Esc>:call DNP_PerlCritic({'mode': 'insert', 'severity': 4})<CR>
if !hasmapto( '<Plug>DnT4N' )
	nmap <buffer> <unique> <LocalLeader>c4 <Plug>DnT4N
endif
nmap <buffer> <unique> <Plug>DnT4N :call DNP_PerlCritic({'mode': 'normal', 'severity': 4})<CR>

" c3 = harsh
if !hasmapto( '<Plug>DnC3I' )
	imap <buffer> <unique> <LocalLeader>c3 <Plug>DnC3I
endif
imap <buffer> <unique> <Plug>DnC3I <Esc>:call DNP_PerlCritic({'mode': 'insert', 'severity': 3})<CR>
if !hasmapto( '<Plug>DnT3N' )
	nmap <buffer> <unique> <LocalLeader>c3 <Plug>DnT3N
endif
nmap <buffer> <unique> <Plug>DnT3N :call DNP_PerlCritic({'mode': 'normal', 'severity': 3})<CR>

" c2 = cruel
if !hasmapto( '<Plug>DnC2I' )
	imap <buffer> <unique> <LocalLeader>c2 <Plug>DnC2I
endif
imap <buffer> <unique> <Plug>DnC2I <Esc>:call DNP_PerlCritic({'mode': 'insert', 'severity': 2})<CR>
if !hasmapto( '<Plug>DnT2N' )
	nmap <buffer> <unique> <LocalLeader>c2 <Plug>DnT2N
endif
nmap <buffer> <unique> <Plug>DnT2N :call DNP_PerlCritic({'mode': 'normal', 'severity': 2})<CR>

" c1 = brutal
if !hasmapto( '<Plug>DnC1I' )
	imap <buffer> <unique> <LocalLeader>c1 <Plug>DnC1I
endif
imap <buffer> <unique> <Plug>DnC1I <Esc>:call DNP_PerlCritic({'mode': 'insert', 'severity': 1})<CR>
if !hasmapto( '<Plug>DnT1N' )
	nmap <buffer> <unique> <LocalLeader>c1 <Plug>DnT1N
endif
nmap <buffer> <unique> <Plug>DnT1N :call DNP_PerlCritic({'mode': 'normal', 'severity': 1})<CR>

" ------------------------------------------------------------------------

" Commands:                                                           {{{2

" :Tidy                                                               {{{3
command! -buffer Tidy call DNP_PerlTidy({'mode': 'normal'})

" :Critic X (where X is 1,2,3,4 or 5)                                 {{{3
command! -buffer -nargs=1 -complete=customlist,s:severity_completion Critic call DNP_PerlCritic({'mode': 'normal', 'severity': <args>})

" }}}1

" vim: set foldmethod=marker :
