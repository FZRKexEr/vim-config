let g:plug_url_format='https://ghproxy.com/https://github.com/%s'

if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://ghproxy.com/https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | source ~/.vimrc
endif

call plug#begin()
  Plug 'aperezdc/vim-template'
  Plug 'skywind3000/vim-auto-popmenu'
  Plug 'skywind3000/vim-dict'
  Plug 'ryanoasis/vim-devicons'
  Plug 'dense-analysis/ale'
  Plug 'sainnhe/everforest'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'wincent/terminus'
  Plug 'thaerkh/vim-workspace'
  Plug 'yianwillis/vimcdoc'
call plug#end()

filetype plugin on
set encoding=UTF-8
set fileformats=unix,dos,mac
set autochdir

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set cindent
set clipboard=unnamed

set number
set signcolumn=yes
set hlsearch
set wrap

set termguicolors
syntax on
set background=dark
colorscheme everforest
" leader
let mapleader = ' '

" macvim 
if has('gui_macvim')
  autocmd GUIEnter * set vb t_vb=
endif

if has('gui_running')
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
    set guifont=UbuntuMonoNerdFontCompleteM-Regular:h16
endif

" Compile and run
nnoremap <space>r :call CodeRunner() <CR>

function! CodeRunner() 
  silent execute 'w'
  let l:run = 'AsyncRun -mode=term -pos=right -save=1 '
  let l:cmd = {}

  if executable('g++-11')
    let l:cmd['cpp'] = "g++-11 -DLOCAL -std=c++17 -Wall -O2 \"$(VIM_FILEPATH)\" && ./a.out"
  else
    let l:cmd['cpp'] = "g++ -DLOCAL -std=c++17 -Wall -O2 \"$(VIM_FILEPATH)\" && ./a.out"
  endif

  let l:cmd['cpp'] = "-post=silent\\ execute\\ '!rm\\ a.out' " . l:cmd['cpp']
  let l:cmd['python'] = 'python3 % '
  let l:cmd['lua'] = 'lua % '
  let l:cmd['sh'] = 'sh % '

  if has_key(cmd, &filetype)
    execute l:run . l:cmd[&filetype]
  else
    echo 'Unsupported language'
  endif
endfunction

" Ale
let g:ale_linters = {'cpp': ['cc']}

if executable('g++-11')
  let g:ale_cpp_cc_executable = 'g++-11' 
else
  let g:ale_cpp_cc_executable = 'g++' 
endif

let g:ale_cpp_cc_options = '-DLOCAL -std=c++17 -Wall -O2'
let g:ale_cpp_cppcheck_options = '-DLOCAL -std=c++17 -Wall -O2'

" buffer and windows
nnoremap <S-l> :bn<CR>
nnoremap <S-h> :bp<CR>
nnoremap <space>q :bd<CR>

" autosave
let g:workspace_autosave_always = 1

" auto popmenu
let g:apc_enable_ft = {'text':1, 'markdown':1, 'cpp':1, 'python':1}
set cpt=.,k,w,b
set completeopt=menu,menuone,noselect
set shortmess+=c

" template
let g:templates_no_builtin_templates=1
" let g:templates_directory='$HOME/.config/nvim/template'
let g:templates_global_name_prefix='template'
let g:templates_name_prefix='template.local'
let g:templates_detect_git=1

