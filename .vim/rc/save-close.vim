" Vim configuration: saving and closing buffers

" Reread file if changed outside vim                                   {{{1
set autoread

" History                                                              {{{1
" - don't keep a backup file
set nobackup
" - remember marks for 20 previous files
" - keep 50 lines of registers
set viminfo='20,<50
" - keep maximum command line history
set history=10000
" - save undo history in a file
set undofile
" - avoid clutter of backup|swap|undo files in local dir
if VrcOS() ==# 'unix'
    set directory=./backup,~/var/vim/swap,.,/tmp
    set backupdir=./backup,~/var/vim/backup,.,/tmp
    set undodir=./backup,~/var/vim/undo,.,/tmp
endif
if VrcOS() ==# 'windows'
    set directory=C:/Windows/Temp
    set backupdir=C:/Windows/Temp
    set undodir=C:/Windows/Temp
endif

" Autosave if buffer loses focus                                       {{{1
set autowrite
" - function VrcSaveOnFocusLost()                                      {{{2
"   intent: save buffer if focus is lost
"   params: nil
"   return: nil
function! VrcSaveOnFocusLost()
    " E141 = no file name for buffer
    try
        :wall
    catch /^Vim\((\a\+)\)\=:E141:/ |
    endtry
endfunction                                                          " }}}2
augroup vrc_save_on_focus_lost
    autocmd!
    autocmd FocusLost * call VrcSaveOnFocusLost()
augroup END

" Save and exit mappings                                               {{{1
" - save file [N,V,I] : <C-s>
nnoremap <C-s> :update<CR>
vnoremap <C-s> <Esc>:update<CR>gv
inoremap <C-s> <Esc>:update<CR>:execute "normal l"<CR>:startinsert<CR>
" - save and exit [V,I] : ZZ
inoremap ZZ <Esc>ZZ
vnoremap ZZ <Esc>ZZ
" - quit without saving [V,I] : ZQ
inoremap ZQ <Esc>ZQ
vnoremap ZQ <Esc>ZQ
" - update and switch windows [N,I] : <C-w><C-w>
inoremap <C-w><C-w> <Esc>:update<CR><C-w><C-w>
nnoremap <C-w><C-w> :update<CR><C-w><C-w>

" Exit automatically if last window is a NERDTree                      {{{1
" - function VrcExitOnNerdtree()                                       {{{2
"   intent: exit if only window open is a NERDTree
"   params: nil
"   return: nil
function! VrcExitOnNerdtree()
    " all these conditions must be satisfied
    if winnr('$') != 1         | return | endif
    if !exists('b:NERDTree')   | return | endif
    if !b:NERDTree.isTabTree() | return | endif
    " all conditions met, so exit
    quit
endfunction                                                          " }}}2
augroup vrc_close_on_nerdtree                                        " {{{2
    autocmd!
    autocmd BufEnter * call VrcExitOnNerdtree()
augroup END                                                          " }}}3

" vim: set foldmethod=marker :
