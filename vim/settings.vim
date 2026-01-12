let g:mapleader = "\<Space>"		        " Set leader key
set nocompatible                        " Not compatible with Vi.
set autoindent                          " Good auto indent
set incsearch                           " Highlight as you search
set ruler              			            " Show the cursor position all the time
set showcmd				                      " Show cmd being typed
set wildmenu				                    " Visual autocmplete for cmd menu
let g:netrw_banner=0                    " Hide banner
let g:netrw_liststyle=3                 " Tree-like listing style
let g:netrw_browse_split=2              " Open file in vertical split
set hidden                              " Required to keep multiple buffers open multiple buffers
set nowrap                              " Display long lines as just one line
set textwidth=200			                  " Text width
set encoding=utf-8                      " The encoding displayed
set pumheight=10                        " Makes popup menu smaller
set fileencoding=utf-8                  " The encoding written to file
set virtualedit=all			                " Allows to navigate in white space
set iskeyword+=-                      	" treat dash separated words as a word text object"
set mouse=a                             " Enable your mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set tabstop=2                           " Insert 2 spaces for a tab
set softtabstop=2			                  " Number of spaces in tab when editing
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set expandtab                           " Converts tabs to spaces
set smartindent                         " Makes indenting smart
set lazyredraw			                    " Only redraw when needed
set showmatch				                    " Highlight matching [{()}]
set incsearch				                    " Show partial matches while searching
set nobackup                            " Don’t create that backup
set nowritebackup                       " Don’t create a temporary backup when saving
set noswapfile                          " Dont't create swap files
set formatoptions-=cro                  " Stop newline continution of comments
set clipboard=unnamedplus               " Copy paste between vim and everything else
set number                              " Show line numbers
set background=dark
syntax on
filetype plugin on                      " Plugins used based on file type at hand.
filetype plugin indent on               " Auto indent based on filetype.