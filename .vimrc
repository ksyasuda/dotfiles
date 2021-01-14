syntax on
set laststatus=2		"enable status bar
set number				"turn on line numbers
set colorcolumn=80		"set color column on col 80
set tw=80				
set shiftwidth=4		
set tabstop=4			
set autoindent			"auto indents code
set smartindent			"smart indents code
set hlsearch			"hilight search
set smartcase			"set search case based on search query
set noerrorbells		"no error bells
set title				"set title of vim based on file open
set mouse=a             " enable mouse in vim

set encoding=UTF-8
set guifont=FiraCode\ Nerd\ Font\ 18

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'valloric/youcompleteme'

Plug 'sheerun/vim-polyglot'

Plug 'vim-scripts/SQLUtilities'

Plug 'ryanoasis/vim-devicons'

Plug 'itchyny/vim-gitbranch'

Plug 'ap/vim-css-color'

Plug 'wakatime/vim-wakatime'

Plug 'jbgutierrez/vim-better-comments'

Plug 'itchyny/lightline.vim'

Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

Plug 'jiangmiao/auto-pairs'

Plug 'mhinz/vim-startify'

Plug 'alvan/vim-closetag'

Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'ntk148v/vim-horizon'
Plug 'ghifarit53/tokyonight-vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'tomasr/molokai'
Plug 'joshdick/onedark.vim'

call plug#end()


"vim-closetag
" filenames like *.xml, *.html, *.xhtml, ...
" These are the file extensions where this plugin is enabled.
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js,*.ts,*.jsx,*.tsx'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.tsx,*.js,*.ts'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,xhtml,phtml'

" filetypes like xml, xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx,js'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" Disables auto-close if not in a "valid" region (based on filetype)

let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }

let g:ycm_autoclose_preview_window_after_insertion = 1 "close ycm help window after accepting option
" let g:ycm_autoclose_preview_window_after_completion = 1

let g:wakatime_PythonBinary = '/usr/bin/python'  " (Default: 'python')
let g:wakatime_OverrideCommandPrefix = '/usr/bin/wakatime'  " (Default: '')

"Markdown preview
let vim_markdown_preview_github=1
let vim_markdown_preview_toggle=1
let vim_markdown_preview_temp_file=0

"NERDTREE
autocmd vimenter * NERDTree "launch nerdtree on vim start
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeWinPos = "right" "open nerdtree on the right
let NERDTreeShowHidden=0 "show hidden files use capital 'I' to toggle
autocmd VimEnter * wincmd p "put the cursor back into the editing pane on start
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }
let g:NERDTreeGitStatusUseNerdFonts = 1
" If more than one window and previous buffer was NERDTree, go back to it.
autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif
"avoid crashes when calling vim-plug functions while the cursor is on the NERDTree window
let g:plug_window = 'noautocmd vertical topleft new'

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

"NERDTree hilight files by extension
call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#282c34')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#282c34')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#282c34')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#282c34')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#282c34')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#282c34')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#282c34')
call NERDTreeHighlightFile('html', 'red', 'none', 'yellow', '#282c34')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#282c34')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#282c34')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#282c34')
call NERDTreeHighlightFile('js', 'yellow', 'none', '#ffa500', '#282c34')
call NERDTreeHighlightFile('jsx', 'yellow', 'none', '#ffa500', '#282c34')
call NERDTreeHighlightFile('tsx', 'yellow', 'none', '#ffa500', '#282c34')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#282c34')
call NERDTreeHighlightFile('cpp', 'blue', 'none', 'blue', '#282c34')
call NERDTreeHighlightFile('h', 'cyan', 'none', 'cyan', '#282c34')
call NERDTreeHighlightFile('txt', 'blue', 'none', 'red', '#282c34')

let g:NERDTreeColorMapCustom = {
    \ "Modified"  : ["#528AB3", "NONE", "NONE", "NONE"],
    \ "Staged"    : ["#538B54", "NONE", "NONE", "NONE"],
    \ "Untracked" : ["#BE5849", "NONE", "NONE", "NONE"],
    \ "Dirty"     : ["#299999", "NONE", "NONE", "NONE"],
    \ "Clean"     : ["#87939A", "NONE", "NONE", "NONE"]
    \ }

"PRETTIER
packloadall "enable prettier
let g:prettier#autoformat = 1
let g:prettier#config#tab_width = 2
let g:prettier#config#print_width = 80
let g:prettier#config#use_tabs = 'true'

"LIGHTLINE
" 'onedark', 'material', 'darcula'
let g:lightline = {
      \ 'colorscheme': 'deus',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste', 'gitbranch' ],
      \             [ 'readonly', 'filename', 'modified',  ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'charvaluehex', 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
	  \ 'component': {
	  \   'charhexvalue': '0x%B'
	  \ },
      \ }

"COLORSCHEME
if !has('gui_running')
  set t_Co=256
endif

set termguicolors

set noshowmode "disable default vim insert text at bottom
let g:onedark_termcolors=256 "enable 256 colors
packadd! onedark.vim "add onedark colorcheme may not work
colorscheme onedark  "set colorsheme as onedark

"Tokyo night conifg
let g:tokyonight_style='night'
let g:tokyonight_transparent_background=1
let g:tokyonight_enable_italic=1

"let g:molokai_original = 1
let g:rehash256 = 1

"KEYBINDINGS
map <C-c> :nohls<Cr>
map <F2> :NERDTreeToggle<CR>
map <C-s> <Plug>(Prettier)
map<C-c> :nohls<CR>
map <C-`> <Esc>:WakaTimeToday<CR>
map <F5> :!{}
