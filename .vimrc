syntax on				
set laststatus=2		
set number				
set colorcolumn=80		
set tw=80				
set shiftwidth=4		
set tabstop=4			
set autoindent			
set smartindent			
set hlsearch			
set smartcase			
set noerrorbells		
set title				
autocmd vimenter * NERDTree
autocmd VimEnter * wincmd p
let g:NERDTreeWinPos = "right"

let g:onedark_termcolors=256

packadd! onedark.vim
colorscheme onedark

let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }
