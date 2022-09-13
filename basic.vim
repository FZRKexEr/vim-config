" 9 lines vimrc for XCPC !
" Created by LiZnB
set nu et cindent wrap hls hid
set ts=2 sts=2 shiftwidth=2
syntax on
set clipboard=unnamed
nnoremap <space>r :call Run() <CR><CR>
fu! Run()
  silent exe 'w'
  exe '!g++ % -std=c++17 -Wall -O2 && a.exe'
endf
