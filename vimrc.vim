let g:plug_url_format='https://ghproxy.com/https://github.com/%s'

if(has('mac') || has('unix'))
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://ghproxy.com/https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall | source ~/.vimrc
  endif
endif

call plug#begin()
  Plug 'thaerkh/vim-workspace'
  Plug 'aperezdc/vim-template'
  Plug 'skywind3000/vim-auto-popmenu'
  Plug 'skywind3000/vim-dict'
  Plug 'dense-analysis/ale'
  Plug 'sainnhe/sonokai'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'wincent/terminus'
  Plug 'yianwillis/vimcdoc'
call plug#end()

autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" core options
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
set whichwrap+=<,>
set backspace=eol,indent

set number
set signcolumn=yes
set hlsearch
set wrap

syntax on
let mapleader = ' '

" colorscheme - sonokai
if has('termguicolors')
  set termguicolors
endif
let g:sonokai_style = 'default'
let g:sonokai_better_performance = 1
colorscheme sonokai


" macvim and gvim
if has('gui_macvim')
  autocmd GUIEnter * set vb t_vb=
  set guifont=UbuntuMono\ Nerd\ Font\ Mono:h16
elseif has('gui_running')
  set guioptions-=T
  set guioptions-=e
  set t_Co=256
  set guitablabel=%M\ %t
  if has('unix')
    set guifont=UbuntuMono\ Nerd\ Font\ Mono\ 18
  else
    set guifont=UbuntuMono_Nerd_Font_Mono:h18:cANSI:qDRAFT
  endif
endif

" Compile and run
nnoremap <space>r :call CodeRunner() <CR>

function! CodeRunner()
  if (has('unix') || has('gui_running'))
    silent execute 'w'
    let l:run = 'AsyncRun -mode=term -pos=right -save=1 '
    let l:cmd = {}
    let l:cmd['cpp'] = " -DLOCAL -std=c++17 -Wall -O2 \"$(VIM_FILEPATH)\" && "

    if executable('g++-11')
      let l:cmd['cpp'] = 'g++-11' . l:cmd['cpp']
    else
      let l:cmd['cpp'] = 'g++' . l:cmd['cpp']
    endif

    if has('unix')
      let l:cmd['cpp'] = l:cmd['cpp'] . './a.out'
    else
      let l:cmd['cpp'] = l:cmd['cpp'] . 'a.exe'
    endif
    
    " windows and terminal vim can't automatic cleanup (No solution has been found so far.)
    if (has('nvim') || has('gui_macvim'))
      let l:cmd['cpp'] = "-post=silent\\ execute\\ '!rm\\ a.out' " . l:cmd['cpp']
    endif

    let l:cmd['python'] = 'python3 % '
    let l:cmd['lua'] = 'lua % '
    let l:cmd['sh'] = 'sh % '

    if has_key(cmd, &filetype)
      execute l:run . l:cmd[&filetype]
    else
      echo 'Unsupported language'
    endif
  else
    echo 'On windows, it can only be compiled and run in gvim'
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
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" autosave
let g:workspace_autosave_always = 1

" auto popmenu
let g:apc_enable_ft = {'text':1, 'markdown':1, 'cpp':1, 'python':1}
set complete=.,k,w,b
set completeopt=menu,menuone,noselect
set shortmess+=c

" template
let g:templates_no_builtin_templates=1
let g:templates_global_name_prefix='template'
let g:templates_name_prefix='template.local'
let g:templates_detect_git=1
