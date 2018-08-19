" Vim configuration: debug

" Python not working in nvim under windows
function! s:DebugPython()
    " python2 checks    {{{2
    echo "\nChecking python2 availability:"
    " does nvim think it has python?    {{{3
    echo '- nvim:   has python2 = ' . has('python')
    " is python available on system using g:python_host_prog?    {{{3
    echo '- system: g:python_host_prog --version = '
    echon systemlist([g:python_host_prog, '--version'])[0]
    " is python available using raw 'python'?    {{{3
    echo "- system: get version using raw 'python' = "
    let g:prog_cmd = 
            \ '"import sys; ' .
            \ 'sys.path.remove(''''); ' .
            \ 'sys.stdout.write(str(sys.version_info[0]) + ''.'' + ' .
            \ 'str(sys.version_info[1])); import pkgutil; ' .
            \ 'exit(2*int(pkgutil.get_loader(''neovim'') is None))"'
    let g:prog_ver = system([ 'python', '-c' , g:prog_cmd ])
    echon 'Python ' . g:prog_ver
    " does python 'neovim' module load?    {{{3
    echo "- system: import python module 'neovim'"
    echo '          (using g:python_host_prog)'
    echo '          (no feedback below this line means success)'
    echo system([g:python_host_prog, '-c', '"import neovim"'])
    " python3 checks    {{{2
    echo "\nChecking python3 availability:"
    " does nvim think it has python3?    {{{3
    echo '- nvim:   has python3 = ' . has('python3')
    " is python3 available on system?    {{{3
    echo '- system: g:python3_host_prog --version = '
    echon systemlist([g:python3_host_prog, '--version'])[0]
    " does python3 'neovim' module load?    {{{3
    " - weirdly, nvim-qt crashes ('Neovim is taking too long to
    "   respond') if any of the next three lines are uncommented;
    "   explanation unknown
"    echo "- system: import python3 module 'neovim'"
"    echo '          (using g:python3_host_prog)'
"    echo '          (no feedback below this line means success)'
    echo system([g:python3_host_prog, '-c', '"import neovim"'])
    echo "\n" |    " }}}3
    " }}}2
endfunction

if dn#rc#os() ==# 'windows' && has('nvim')
    call s:DebugPython()
endif

" vim:foldmethod=marker:
