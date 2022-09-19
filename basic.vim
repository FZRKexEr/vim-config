" Basic vimrc for ArchLinux
" Created by LiZnB

" Core
set nu et cin wrap hls hid
set ts=2 sts=2 sw=2 scl=yes
syntax on
nnoremap <space>r :call Run() <CR>
fu! Run()
  silent exe 'w'
  exe '!g++ -std=c++17 -Wall -Wextra -Wshadow -fsanitize=address -O2 % && ./a.out'
endf

" Gui
set gfn=UbuntuMono\ Nerd\ Font\ Mono\ 14
set go-=T go-=e gcr=a:blinkon0

" Plugins (Optional) 
call plug#begin()
  Plug 'dense-analysis/ale'
  Plug 'sainnhe/sonokai'
call plug#end()

colo sonokai
let g:ale_linters = {'cpp': ['cc', 'cppcheck']}
let g:ale_cpp_cc_executable = 'g++'
let g:ale_cpp_cc_options = '-std=c++17 -Wall -Wextra -fsanitize=address -Wshadow -O2'
