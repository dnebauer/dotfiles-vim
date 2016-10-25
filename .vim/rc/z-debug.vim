" Vim configuration: debug

" Python not working in nvim under windows                             {{{1
function! s:DebugPython()
    " python2 checks                                                   {{{2
    echo 'Checking python2 availability:'
    " check whether nvim thinks it has python                          {{{3
    echo '- has python2: ' . has('python')
    " check whether python available on system                         {{{3
    echo '- g:python_host_prog --version: '
    echon systemlist([g:python_host_prog, '--version'])[0]
    " check python system availability by alternate method             {{{3
    echo "- alternate method using raw 'python': "
    let g:prog_cmd = 
            \ '"import sys; ' .
            \ 'sys.path.remove(''''); ' .
            \ 'sys.stdout.write(str(sys.version_info[0]) + ''.'' + ' .
            \ 'str(sys.version_info[1])); import pkgutil; ' .
            \ 'exit(2*int(pkgutil.get_loader(''neovim'') is None))"'
    let g:prog_ver = system([ 'python', '-c' , g:prog_cmd ])
    echon 'Python ' . g:prog_ver
    " test for python 'neovim' module                                  {{{3
    echo "- import python module 'neovim' on system:"
    echo '  (using g:python_host_prog)'
    echo '  (no feedback below this line means success)'
    echo system([g:python_host_prog, '-c', '"import neovim"'])
    " python3 checks                                                   {{{2
    echo 'Checking python3 availability:'
    echo '- has python3: ' . has('python3')
    " check whether python3 available on system                        {{{3
    echo '- g:python3_host_prog --version: '
    echon systemlist([g:python3_host_prog, '--version'])[0]
    " test for python 'neovim' module                                  {{{3
    echo "- import python3 module 'neovim' on system:"
    echo '  (using g:python3_host_prog)'
    echo '  (no feedback below this line means success)'
    echo system([g:python3_host_prog, '-c', '"import neovim"'])
    " control check                                                    {{{2
    echo 'Control check:'
    echo '- clipboard: ' . has('clipboard')                        | " }}}2
endfunction                                                          " }}}1

if VrcOS() ==# 'windows' && exists(':terminal')
    call s:DebugPython()
endif

" vim: set foldmethod=marker :
