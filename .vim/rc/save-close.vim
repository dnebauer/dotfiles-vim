" Vim configuration: saving and closing buffers

" Reread file if changed outside vim    {{{1
set autoread

" History    {{{1
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
if dn#rc#os() ==# 'unix'
    set directory=$HOME/.cache/vim/swap,.,/tmp
    set backupdir=$HOME/.cache/vim/backup,.,/tmp
    set undodir=$HOME/.cache/vim/undo,.,/tmp
endif
if dn#rc#os() ==# 'windows'
    set directory=C:/Windows/Temp
    set backupdir=C:/Windows/Temp
    set undodir=C:/Windows/Temp
endif

" Autosave if buffer loses focus    {{{1
set autowrite
augroup vrc_save_on_focus_lost
    autocmd!
    autocmd FocusLost * call dn#rc#saveOnFocusLost()
augroup END

" Save and exit mappings    {{{1
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
" }}}1

" vim:foldmethod=marker:
