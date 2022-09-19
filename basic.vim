" 9 lines vimrc for XCPC !
" Created by LiZnB
set nu et cin wrap hls hid
set ts=2 sts=2 sw=2 cb=unnamed
syntax on
nnoremap <space>r :call Run() <CR><CR>
fu! Run()
  silent exe 'w'
  exe '!g++ % -std=c++17 -Wall -Wextra -Wshadow -O2 && a.exe'
endf
set guifont=Fixedsys:h18
