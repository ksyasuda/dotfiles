nmap <C-u> <C-u>zz
nmap n nzzzv
nmap N Nzzzv

" paste visually without yanking to clipboard
xnoremap <leader>p "_dP

" reselect visual selection after indent
vnoremap < <gv
vnoremap > >gv

" move selected line(s) up or down and respect indent
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" search
nnoremap // :Telescope current_buffer_fuzzy_find<CR>
nnoremap ?? :Telescope lsp_document_symbols<CR>

" nnoremap Q !!$SHELL<CR>
" nnoremap rn :lua vim.lsp.buf.rename()<CR>

nnoremap <C-J> :bnext<CR>
nnoremap <C-K> :bprev<CR>

nnoremap <C-T> :wa<CR>:FloatermToggle floatterm<CR>
tnoremap <C-T> <C-\><C-n>:FloatermToggle floatterm<CR>
tnoremap <Esc> <C-\><C-n>
tnoremap <leader>tt <C-\><C-N>:FloatermToggle split-term<CR>
tnoremap <leader>tf <C-\><C-N>:FloatermToggle floatterm<CR>
tnoremap <leader>tp <C-\><C-N>:FloatermToggle ipython<CR>
tnoremap <leader>tP <C-\><C-N>:FloatermToggle ipython-full<CR>


nnoremap gA :lua vim.lsp.buf.code_actions()<CR>
nnoremap gd :Telescope lsp_definitions<CR>
nnoremap gDc :Telescope lsp_implementations<CR>
nnoremap gDf :Telescope lsp_definitions<CR>
nnoremap gF :edit <cfile><CR>
nnoremap gT :Telescope lsp_type_definitions<CR>
nnoremap gb :Gitsigns blame_line<CR>
nnoremap gi :Telescope lsp_implementations<CR>
nnoremap gj :Telescope jumplist<CR>
nnoremap gl :lua vim.lsp.buf.code_lens()<CR>
nnoremap gr :Telescope lsp_references<CR>
nnoremap gs :lua vim.lsp.buf.signature_help()<CR>

nnoremap <leader>bb :Telescope buffers<CR>
nnoremap <leader>bk :bdelete<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>

nnoremap <leader>ca :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>cA :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>cd :Telescope diagnostics<CR>
nnoremap <leader>cDn :lua vim.diagnostic.goto_next()<CR>
nnoremap <leader>cDp :lua vim.diagnostic.goto_prev()<CR>
nnoremap <leader>cl :lua vim.diagnostic.setloclist()<CR>
nnoremap <silent> <leader>cp :vert Copilot panel<CR>
nnoremap <silent> <leader>Ci :lua require('chatgpt').edit_with_instructions()<CR>
nnoremap <silent> <leader>Cd :ChatGPTRun docstring<CR>
nnoremap <silent> <leader>Ct :ChatGPTRun add_tests<CR>
nnoremap <silent> <leader>Co :ChatGPTRun optimize_code<CR>
nnoremap <silent> <leader>Cs :ChatGPTRun summarize<CR>
nnoremap <silent> <leader>Cf :ChatGPTRun fix_bugs<CR>
nnoremap <silent> <leader>Ce :ChatGPTRun explain_code<CR>
xnoremap <silent> <leader>Ci :lua require('chatgpt').edit_with_instructions()<CR>
xnoremap <silent> <leader>Cd :ChatGPTRun docstring<CR>
xnoremap <silent> <leader>Ct :ChatGPTRun add_tests<CR>
xnoremap <silent> <leader>Co :ChatGPTRun optimize_code<CR>
xnoremap <silent> <leader>Cs :ChatGPTRun summarize<CR>
xnoremap <silent> <leader>Cf :ChatGPTRun fix_bugs<CR>
xnoremap <silent> <leader>Ce :ChatGPTRun explain_code<CR>

nnoremap <leader>db :lua require("dap").toggle_breakpoint()<CR>
nnoremap <leader>dc :lua require("dap").continue()<CR>
nnoremap <leader>di :lua require("dap").step_into()<CR>
nnoremap <leader>do :lua require("dap").step_over()<CR>
nnoremap <leader>dO :lua require("dap").step_out()<CR>
nnoremap <leader>dr :lua require("dap").repl.open()<CR>
nnoremap <leader>dl :lua require("dap").run_last()<CR>
nnoremap <leader>dh :lua require("dap.ui.widgets").hover()<CR>
nnoremap <leader>dp :lua require("dap.ui.widgets").preview()<CR>
nnoremap <leader>df :lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<CR>
nnoremap <leader>ds :lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)<CR>
nnoremap <leader>dut :lua require("dapui").toggle()<CR>
nnoremap <leader>duo :lua require("dapui").open()<CR>
nnoremap <leader>duc :lua require("dapui").close()<CR>
nnoremap <leader>dPm :lua require("dap-python").test_method()<CR>
nnoremap <leader>dPc :lua require("dap-python").test_class()<CR>
nnoremap <leader>dPs :lua require("dap-python").debug_selection()<CR>

vnoremap <leader>dh :lua require("dap.ui.widgets").hover()<CR>
vnoremap <leader>dp :lua require("dap.ui.widgets").preview()<CR>
vnoremap <leader>dpe :lua require("dapui").eval()<CR>

nnoremap <F10> :lua require('dap').step_over()<CR>
nnoremap <F11> :lua require('dap').step_into()<CR>
nnoremap <F12> :lua require('dap').step_out()<CR>

nnoremap <leader>D :Dotenv .env<CR>

nnoremap <leader>ec :e ~/.config/nvim/init.vim<CR>
nnoremap <leader>ek :e ~/.config/nvim/keybindings.vim<CR>
nnoremap <leader>ep :e ~/.config/nvim/lua/plugins.lua<CR>
nnoremap <leader>es :e ~/.config/nvim/lua/settings.lua<CR>

nnoremap <leader>fb :Telescope file_browser<CR>
nnoremap <leader>fc :Telescope color_names theme=dropdown layout_config={width=0.45,height=25,prompt_position="bottom"} layout_strategy=vertical<CR>
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>fg :Telescope glyph theme=dropdown layout_config={width=0.45,height=35,prompt_position="bottom"} layout_strategy=vertical<CR>
nnoremap <leader>fr :Telescope oldfiles<CR>

nnoremap <leader>gb :Gitsigns blame_line<CR>
nnoremap <leader>gc :Telescope git_commits<CR>
nnoremap <leader>gf :Telescope git_files<CR>
nnoremap <leader>gg :FloatermNew --title=lazygit --width=1.0 --height=1.0 --opener=vsplit lazygit<CR>
nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>
nnoremap gR <cmd>Telescope lsp_references<CR>
nnoremap gpc <cmd>lua require('goto-preview').close_all_win()<CR>
nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>

nnoremap <leader>hc :Telescope commands<CR>
nnoremap <leader>hdc :Telescope dap commands<CR>
nnoremap <leader>hdC :Telescope dap configurations<CR>
nnoremap <leader>hdb :Telescope dap list_breakpoints<CR>
nnoremap <leader>hdv :Telescope dap variables<CR>
nnoremap <leader>hdf :Telescope dap frames<CR>
nnoremap <leader>hv :Telescope vim_options<CR>
nnoremap <leader>hk :Telescope keymaps<CR>
nnoremap <leader>hs :Telescope spell_suggest<CR>

nnoremap <leader>isp :-1read $HOME/Templates/python.py<CR>4jw

nnoremap <leader>j :AnyJump<CR>

nnoremap K :lua vim.lsp.buf.hover()<CR>

nnoremap <leader>ld :Telescope lsp_definitions<CR>
nnoremap <leader>lD :Telescope diagnostics<CR>
nnoremap <leader>la :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>lci :Telescope lsp_incoming_calls<CR>
nnoremap <leader>lco :Telescope lsp_outgoing_calls<CR>
nnoremap <leader>lh :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>li :Telescope lsp_implementations<CR>
nnoremap <leader>lr :Telescope lsp_references<CR>
nnoremap <leader>lR :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>ls :Telescope lsp_document_symbols<CR>
nnoremap <leader>lt :Telescope lsp_type_definitions<CR>
nnoremap <leader>lw :Telescope lsp_dynamic_workspace_symbols<CR>

nnoremap <leader>n :NvimTreeToggle<CR>
" nnoremap <leader>r :NvimTreeRefresh<CR>


nnoremap <leader>ob :Telescope file_browser<CR>
nnoremap <leader>oc :ChatGPT<CR>
nnoremap <leader>oC :e ~/.config/nvim/init.vim<CR>
nnoremap <leader>oB :FloatermNew --title=btop --opener=vsplit btop<CR>
nnoremap <leader>od :FloatermNew --title=lazydocker --opener=vsplit lazydocker<CR>
nnoremap <leader>of :wa<CR>:FloatermToggle floatterm<CR>
nnoremap <leader>oh :FloatermNew --title=floaterm --name=split-term --opener=edit --wintype=split --position=botright --height=0.45<CR>
nnoremap <leader>on :FloatermNew --title=ncmpcpp --opener=vsplit ncmpcpp<CR>
nnoremap <leader>op :FloatermNew --title=ipython --name=ipython --opener=split --wintype=vsplit --position=botright --width=0.5 ipython<CR>
nnoremap <leader>oP :FloatermNew --title=ipython-full --name=ipython-full --opener=edit --width=1.0 --height=1.0 ipython<CR>
nnoremap <leader>or :FloatermNew --title=ranger --opener=vsplit ranger --cmd="cd $PWD"<CR>
nnoremap <leader>ot :FloatermNew --title=floaterm --name=split-term --opener=edit --wintype=vsplit --position=botright --width=0.5<CR>

nnoremap <leader>sc :nohls<CR>
nnoremap <leader>sC :Telescope commands<CR>
nnoremap <leader>sf :Telescope find_files<CR>
nnoremap <leader>sg :Telescope live_grep<CR>
nnoremap <leader>sh :Telescope command_history<CR>
nnoremap <leader>sm :Telescope man_pages<CR>
nnoremap <leader>s/ :Telescope search_history<CR>

nnoremap <silent> <Leader>tc :Telescope colorscheme<CR>
nnoremap <silent> <leader>tf :wa<CR>:FloatermToggle floatterm<CR>
nnoremap <silent> <leader>tp :FloatermToggle ipython<CR>
nnoremap <silent> <leader>tP :FloatermToggle ipython-full<CR>
nnoremap <silent> <leader>tt :FloatermToggle split-term<CR>
nnoremap <silent> <leader>td :DBUIToggle<CR>
nnoremap <silent> <leader>Tc :Telescope color_names theme=dropdown layout_config={width=0.45,height=25,prompt_position="bottom"} layout_strategy=vertical<CR>
nnoremap <silent> <leader>Tg :Telescope glyph theme=dropdown layout_config={width=0.45,height=35,prompt_position="bottom"} layout_strategy=vertical<CR>
nnoremap <silent> <leader>Tn :Telescope notify<CR>
nnoremap <silent> <leader>Tt :Telescope<CR>

nnoremap <leader>wa :lua vim.lsp.buf.add_workspace_folder()<CR>
nnoremap <leader>wl :lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>
nnoremap <leader>wr :lua vim.lsp.buf.remove_workspace_folder()<CR>

nmap <silent> <leader>x <cmd>!chmod +x %<CR>

nnoremap <leader>y "+
vmap <leader>y "+
