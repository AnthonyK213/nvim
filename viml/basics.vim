filetype on
filetype indent on
filetype plugin on
syntax enable


" Appearance
set ruler
set number
set hidden
set cursorline
set cmdheight=1
set scrolloff=5
set laststatus=2
set colorcolumn=80
set shortmess+=c
set noshowmode showcmd
set list listchars=tab:>-,trail:·
"" Set 'background' during startup to disable the background detection.
set background=dark


" Language, encode
set encoding=utf-8
set fencs=utf-8,chinese,ucs-bom,latin-1,shift-jis,gb18030,gbk,gb2312,cp936
set fileformats=unix,dos,mac
set formatoptions+=mB


" Behavior
set autoindent smartindent
set tabstop=2 shiftwidth=2 softtabstop=2
set wrap linebreak showbreak=^
set expandtab smarttab
set backspace=2
set splitbelow splitright
set noerrorbells novisualbell
set winaltkeys=no
set history=500
set updatetime=300
set notimeout ttimeoutlen=0
set completeopt=menu,menuone,noselect


" Search
set hlsearch incsearch
set ignorecase smartcase


" File
set nobackup nowritebackup
set noswapfile noundofile
set autoread autowrite
set confirm
