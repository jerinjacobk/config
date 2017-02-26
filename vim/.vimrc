set background=light
filetype plugin on
highlight OverLength ctermbg=white ctermfg=red guibg=#ff0000
match OverLength /\%81v.\+/
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/
"se nu
set cc=80
:autocmd FileType mail :nmap <F8> :w<CR>:!aspell -e -c %<CR>:e<CR>
hi Comment ctermfg=Brown
syntax enable
