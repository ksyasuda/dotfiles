syntax on				"enable syntax hilighting 
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

let vim_markdown_preview_github=1
let vim_markdown_preview_toggle=1
let vim_markdown_preview_temp_file=0

autocmd vimenter * NERDTree "launch nerdtree on vim start
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeWinPos = "right" "open nerdtree on the right
autocmd VimEnter * wincmd p "put the cursor back into the editing pane on start

"map open NERDTree to F2
map <F2> :NERDTreeToggle<CR>
let g:onedark_termcolors=256 "enable 256 colors

if !has('gui_running')
  set t_Co=256
endif

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  set termguicolors
endif

packadd! onedark.vim "add onedark colorcheme may not work
colorscheme onedark  "set colorsheme as onedark

"set colorscheme of lightline may nor work
let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }

"NERDTreeGit !might not work
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


"VIMPLUG START 
"nerdtree-git for git integratino to nerdtree prob doesn't work
"youcompleteme for autocompletion
"vim-polyglot for better syntax hilighting
"Auto pairs for paren/bracket pairing
"sqlutilities
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'valloric/youcompleteme'

Plug 'sheerun/vim-polyglot'

Plug 'vim-scripts/SQLUtilities'

call plug#end()

packloadall "enable prettier
let g:prettier#autoformat = 1
let g:prettier#config#tab_width = 4
let g:prettier#config#print_width = 80
let g:prettier#config#use_tabs = 'true'
autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html,*.xml,*.sql PrettierAsync
map <C-s> <Plug>(Prettier)

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

"NERDTree hilight files by extension
call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

"auto-close-tag configuration
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js,*.md'
let g:closetag_xhtml_filenames = '*.html,*.xhtml,*.jsx,*.js,*.md'

"markdown-preview
"let g:mkdp_refresh_slow = 1
"let g:mkdp_markdown_css = '/home/sudacode/.vim/github-markdown.css'
let vim_markdown_preview_github=1
let vim_markdown_preview_toggle=2 "set images to load on write
let vim_markdown_preview_temp_file=1 "remove the rendered preview

"Show coding time today in vim
map <C-`> <Esc>:WakaTimeToday<CR>
