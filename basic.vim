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
set hidden

syntax on
let mapleader = ' '

if has('gui_running')
  set guioptions-=T
  set guioptions-=e
  set t_Co=256
  set guitablabel=%M\ %t
  set guifont=UbuntuMono_Nerd_Font_Mono:h18:cANSI:qDRAFT
endif
