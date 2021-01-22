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
set laststatus=2
set shortmess=atI
set noshowmode showcmd
set list listchars=tab:>-,trail:·


" Language, encode
set encoding=utf-8 termencoding=utf-8
set fileencodings=utf-8,chinese,ucs-bom,latin-1,shift-jis,gb18030,gbk,gb2312,cp936
set fileformats=unix,dos,mac
set formatoptions+=m  " Prevent wrapping when Unicode > 255
set formatoptions+=B  " Prevent space when merge lines in Chinese


" Behavior
set showmatch
set autoindent smartindent
set tabstop=4 shiftwidth=4 softtabstop=4
set wrap linebreak showbreak=>
set expandtab smarttab
set backspace=2
set splitbelow splitright
set noerrorbells novisualbell
set winaltkeys=no
set history=500
set updatetime=300
set notimeout nottimeout


" Search
set hlsearch incsearch
set ignorecase smartcase


" File
set nobackup nowritebackup
set noswapfile noundofile
set autochdir
set autoread autowrite
set confirm
