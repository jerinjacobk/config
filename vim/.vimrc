set showmatch
set smartcase
set background=light
filetype plugin on
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/
set mouse=a
"se nu
set cc=100
highlight OverLength ctermbg=white ctermfg=red guibg=#ffff00
match OverLength /\%101v.\+/
:autocmd FileType mail :nmap <F8> :w<CR>:!aspell -e -c %<CR>:e<CR>
hi Comment ctermfg=Brown
syntax enable
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END
syn match ErrorLeadSpace /^ \+/         " highlight any leading spaces
syn match ErrorTailSpace / \+$/         " highlight any trailing spaces
set hlsearch
nnoremap <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>
set colorcolumn=101
