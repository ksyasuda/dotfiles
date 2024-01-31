-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/sudacode/.cache/nvim/packer_hererocks/2.1.1699392533/share/lua/5.1/?.lua;/home/sudacode/.cache/nvim/packer_hererocks/2.1.1699392533/share/lua/5.1/?/init.lua;/home/sudacode/.cache/nvim/packer_hererocks/2.1.1699392533/lib/luarocks/rocks-5.1/?.lua;/home/sudacode/.cache/nvim/packer_hererocks/2.1.1699392533/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/sudacode/.cache/nvim/packer_hererocks/2.1.1699392533/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["ChatGPT.nvim"] = {
    config = { "\27LJ\2\n»\17\0\0\a\0006\0G6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\b\0005\4\f\0005\5\t\0005\6\n\0=\6\v\5=\5\r\0045\5\14\0=\5\15\4=\4\16\0035\4\18\0005\5\17\0=\5\19\4=\4\6\3=\3\20\0025\3\21\0005\4\22\0=\4\23\0035\4\24\0=\4\25\3=\3\26\0025\3\29\0005\4\27\0005\5\28\0=\5\v\4=\4\r\0035\4\30\0=\4\15\0035\4\31\0=\4 \3=\3!\0025\3$\0005\4\"\0005\5#\0=\5\v\4=\4\r\0035\4%\0=\4\15\3=\3&\0025\3'\0005\4(\0005\5)\0=\5\v\4=\4\r\0035\4*\0=\4\15\3=\3+\0025\3.\0005\4,\0005\5-\0=\5\v\4=\4\r\0035\4/\0=\4\15\3=\0030\0025\0031\0=\0032\0025\0033\0=\0034\0024\3\0\0=\0035\2B\0\2\1K\0\1\0\18actions_paths\23openai_edit_params\1\0\4\16temperature\3\0\nmodel\26code-davinci-edit-001\6n\3\1\ntop_p\3\1\18openai_params\1\0\a\6n\3\1\nmodel\18gpt-3.5-turbo\ntop_p\3\1\16temperature\3\0\15max_tokens\3¬\2\21presence_penalty\3\0\22frequency_penalty\3\0\20settings_window\1\0\1\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\1\0\0\1\0\1\btop\15 Settings \1\0\1\nstyle\frounded\16popup_input\1\0\1\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\1\0\2\btop\r Prompt \14top_align\vcenter\1\0\2\nstyle\frounded\14highlight\16FloatBorder\1\0\4\vsubmit\14<C-Enter>\22max_visible_lines\3\20\vprompt\n ï†’ \rsubmit_n\f<Enter>\18system_window\1\0\4\14linebreak\2\twrap\2\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\15foldcolumn\0062\1\0\0\1\0\1\btop\r SYSTEM \1\0\2\nstyle\frounded\14highlight\16FloatBorder\17popup_window\16buf_options\1\0\1\rfiletype\rmarkdown\1\0\4\14linebreak\2\twrap\2\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\15foldcolumn\0061\1\0\0\1\0\1\btop\14 ChatGPT \1\0\2\nstyle\frounded\14highlight\16FloatBorder\17popup_layout\nright\1\0\2\24width_settings_open\b50%\nwidth\b30%\vcenter\1\0\2\vheight\b80%\nwidth\b80%\1\0\1\fdefault\vcenter\tchat\nclose\1\0\15\14yank_last\n<C-y>\18draft_message\n<C-d>\18cycle_windows\n<Tab>\19rename_session\6r\20toggle_settings\n<C-o>\19select_session\f<Space>\19delete_session\6d\16cycle_modes\n<C-f>\24toggle_message_role\n<C-r>\16new_session\n<C-n>\16scroll_down\n<C-d>\28toggle_system_role_open\n<C-s>\14scroll_up\n<C-u>\20stop_generating\n<C-x>\19yank_last_code\n<C-k>\1\2\0\0\n<C-c>\20sessions_window\16win_options\1\0\1\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\vborder\1\0\0\ttext\1\0\1\btop\15 Sessions \1\0\1\nstyle\frounded\1\0\5\16answer_sign\bï®§\20max_line_length\3x\18question_sign\bï€‡\17loading_text\29Loading, please wait ...\20welcome_message\16HELLO FREUD\27edit_with_instructions\fkeymaps\1\0\6\vaccept\n<C-y>\nclose\n<C-c>\24use_output_as_input\n<C-i>\18cycle_windows\n<Tab>\20toggle_settings\n<C-o>\16toggle_diff\n<C-d>\1\0\1\tdiff\1\1\0\4 predefined_chat_gpt_promptsQhttps://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv\24show_quickfixes_cmd\21Trouble quickfix\18yank_register\6+\16api_key_cmd.cat /home/stickuser/.config/openai/apikey\nsetup\fchatgpt\frequire\0" },
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/ChatGPT.nvim",
    url = "https://github.com/jackMort/ChatGPT.nvim"
  },
  LuaSnip = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["any-jump.vim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/any-jump.vim",
    url = "https://github.com/pechorin/any-jump.vim"
  },
  ["auto-pairs"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/auto-pairs",
    url = "https://github.com/jiangmiao/auto-pairs"
  },
  catppuccin = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-nvim-lsp-document-symbol"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp-document-symbol",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol"
  },
  ["cmp-nvim-lsp-signature-help"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp-signature-help",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua",
    url = "https://github.com/hrsh7th/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["copilot-cmp"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/copilot-cmp",
    url = "https://github.com/zbirenbaum/copilot-cmp"
  },
  ["copilot.lua"] = {
    config = { "\27LJ\2\nÅ\4\0\0\6\0\25\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\n\0005\4\v\0=\4\5\3=\3\f\0026\3\r\0009\3\14\0039\3\15\3'\5\16\0B\3\2\2'\4\17\0&\3\4\3=\3\18\0025\3\19\0005\4\21\0005\5\20\0=\5\22\4=\4\23\3=\3\24\2B\0\2\1K\0\1\0\26server_opts_overrides\rsettings\radvanced\1\0\0\1\0\2\23inlineSuggestCount\3\4\14listCount\3\n\1\0\1\ntrace\fverbose\24plugin_manager_path\22/site/pack/packer\tdata\fstdpath\afn\bvim\15suggestion\1\0\4\tnext\n<M-]>\vaccept\n<C-l>\fdismiss\n<C-]>\tprev\n<M-[>\1\0\3\fenabled\1\rdebounce\3K\17auto_trigger\1\npanel\1\0\1\25copilot_node_command\tnode\vlayout\1\0\2\nratio\4š³æÌ\t™³æþ\3\rposition\nright\vkeymap\1\0\5\topen\v<C-CR>\vaccept\t<CR>\frefresh\agr\14jump_next\a]]\14jump_prev\a[[\1\0\2\fenabled\1\17auto_refresh\1\nsetup\fcopilot\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/opt/copilot.lua",
    url = "https://github.com/zbirenbaum/copilot.lua"
  },
  ["dashboard-nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/dashboard-nvim",
    url = "https://github.com/glepnir/dashboard-nvim"
  },
  ["doom-one.nvim"] = {
    config = { "\27LJ\2\nÑ\1\0\0\3\0\5\0\r6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\1K\0\1\0.highlight PmenuSel guifg=purple guibg=redShighlight Pmenu ctermfg=white ctermbg=black gui=NONE guifg=white guibg=#282C34\25colorscheme doom-one\bcmd\bvim\0" },
    loaded = true,
    needs_bufread = false,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/opt/doom-one.nvim",
    url = "https://github.com/NTBBloodbath/doom-one.nvim"
  },
  ["dracula.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/dracula.nvim",
    url = "https://github.com/Mofiqul/dracula.nvim"
  },
  ["dressing.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/dressing.nvim",
    url = "https://github.com/stevearc/dressing.nvim"
  },
  ["fidget.nvim"] = {
    config = { "\27LJ\2\n8\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\vfidget\frequire\0" },
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/fidget.nvim",
    url = "https://github.com/j-hui/fidget.nvim"
  },
  ["github-nvim-theme"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/github-nvim-theme",
    url = "https://github.com/projekt0n/github-nvim-theme"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["goto-preview"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/goto-preview",
    url = "https://github.com/rmagatti/goto-preview"
  },
  ["lsp_lines.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/lsp_lines.nvim",
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
  },
  ["lspkind-nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/lspkind-nvim",
    url = "https://github.com/onsails/lspkind-nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["neodev.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/neodev.nvim",
    url = "https://github.com/folke/neodev.nvim"
  },
  neorg = {
    config = { "\27LJ\2\nú\1\0\0\a\0\17\0\0236\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\15\0005\3\3\0004\4\0\0=\4\4\0034\4\0\0=\4\5\0035\4\a\0005\5\6\0=\5\b\4=\4\t\0035\4\r\0005\5\v\0005\6\n\0=\6\f\5=\5\b\4=\4\14\3=\3\16\2B\0\2\1K\0\1\0\tload\1\0\0\16core.dirman\1\0\0\15workspaces\1\0\0\1\0\1\nnotes\f~/notes\20core.completion\vconfig\1\0\0\1\0\1\vengine\rnvim-cmp\19core.concealer\18core.defaults\1\0\0\nsetup\nneorg\frequire\0" },
    load_after = {},
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/opt/neorg",
    url = "https://github.com/nvim-neorg/neorg"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-bufferline.lua"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-bufferline.lua",
    url = "https://github.com/akinsho/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-dap"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap"
  },
  ["nvim-dap-python"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-dap-python",
    url = "https://github.com/mfussenegger/nvim-dap-python"
  },
  ["nvim-dap-ui"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-dap-ui",
    url = "https://github.com/rcarriga/nvim-dap-ui"
  },
  ["nvim-dap-virtual-text"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-dap-virtual-text",
    url = "https://github.com/theHamsta/nvim-dap-virtual-text"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-notify"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["onedarkpro.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/onedarkpro.nvim",
    url = "https://github.com/olimorris/onedarkpro.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["presence.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/presence.nvim",
    url = "https://github.com/andweeb/presence.nvim"
  },
  ["rainbow-delimiters.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/rainbow-delimiters.nvim",
    url = "https://github.com/HiPhish/rainbow-delimiters.nvim"
  },
  ["telescope-color-names.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope-color-names.nvim",
    url = "https://github.com/nat-418/telescope-color-names.nvim"
  },
  ["telescope-dap.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope-dap.nvim",
    url = "https://github.com/nvim-telescope/telescope-dap.nvim"
  },
  ["telescope-file-browser.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-glyph.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope-glyph.nvim",
    url = "https://github.com/ghassan0/telescope-glyph.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-dadbod"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-dadbod",
    url = "https://github.com/tpope/vim-dadbod"
  },
  ["vim-dadbod-completion"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-dadbod-completion",
    url = "https://github.com/kristijanhusak/vim-dadbod-completion"
  },
  ["vim-dadbod-ui"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-dadbod-ui",
    url = "https://github.com/kristijanhusak/vim-dadbod-ui"
  },
  ["vim-dotenv"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-dotenv",
    url = "https://github.com/tpope/vim-dotenv"
  },
  ["vim-floaterm"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-wakatime"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-wakatime",
    url = "https://github.com/wakatime/vim-wakatime"
  },
  ["which-key.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: doom-one.nvim
time([[Setup for doom-one.nvim]], true)
try_loadstring("\27LJ\2\n»\6\0\0\2\0\21\0M6\0\0\0009\0\1\0+\1\1\0=\1\2\0006\0\0\0009\0\1\0+\1\2\0=\1\3\0006\0\0\0009\0\1\0+\1\1\0=\1\4\0006\0\0\0009\0\1\0+\1\2\0=\1\5\0006\0\0\0009\0\1\0+\1\1\0=\1\6\0006\0\0\0009\0\1\0+\1\1\0=\1\a\0006\0\0\0009\0\1\0+\1\1\0=\1\b\0006\0\0\0009\0\1\0)\1\20\0=\1\t\0006\0\0\0009\0\1\0+\1\2\0=\1\n\0006\0\0\0009\0\1\0+\1\1\0=\1\v\0006\0\0\0009\0\1\0+\1\2\0=\1\f\0006\0\0\0009\0\1\0+\1\2\0=\1\r\0006\0\0\0009\0\1\0+\1\2\0=\1\14\0006\0\0\0009\0\1\0+\1\2\0=\1\15\0006\0\0\0009\0\1\0+\1\2\0=\1\16\0006\0\0\0009\0\1\0+\1\2\0=\1\17\0006\0\0\0009\0\1\0+\1\2\0=\1\18\0006\0\0\0009\0\1\0+\1\1\0=\1\19\0006\0\0\0009\0\1\0+\1\1\0=\1\20\0K\0\1\0\28doom_one_plugin_lspsaga#doom_one_plugin_vim_illuminate%doom_one_plugin_indent_blankline\29doom_one_plugin_whichkey\29doom_one_plugin_startify\30doom_one_plugin_dashboard\30doom_one_plugin_nvim_tree\27doom_one_plugin_neogit\30doom_one_plugin_telescope\27doom_one_plugin_barbar\26doom_one_plugin_neorg#doom_one_pumblend_transparency\29doom_one_pumblend_enable$doom_one_transparent_background$doom_one_diagnostics_text_color\31doom_one_enable_treesitter\29doom_one_italic_comments\29doom_one_terminal_colors\29doom_one_cursor_coloring\6g\bvim\0", "setup", "doom-one.nvim")
time([[Setup for doom-one.nvim]], false)
time([[packadd for doom-one.nvim]], true)
vim.cmd [[packadd doom-one.nvim]]
time([[packadd for doom-one.nvim]], false)
-- Config for: doom-one.nvim
time([[Config for doom-one.nvim]], true)
try_loadstring("\27LJ\2\nÑ\1\0\0\3\0\5\0\r6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\1K\0\1\0.highlight PmenuSel guifg=purple guibg=redShighlight Pmenu ctermfg=white ctermbg=black gui=NONE guifg=white guibg=#282C34\25colorscheme doom-one\bcmd\bvim\0", "config", "doom-one.nvim")
time([[Config for doom-one.nvim]], false)
-- Config for: fidget.nvim
time([[Config for fidget.nvim]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\vfidget\frequire\0", "config", "fidget.nvim")
time([[Config for fidget.nvim]], false)
-- Config for: ChatGPT.nvim
time([[Config for ChatGPT.nvim]], true)
try_loadstring("\27LJ\2\n»\17\0\0\a\0006\0G6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\b\0005\4\f\0005\5\t\0005\6\n\0=\6\v\5=\5\r\0045\5\14\0=\5\15\4=\4\16\0035\4\18\0005\5\17\0=\5\19\4=\4\6\3=\3\20\0025\3\21\0005\4\22\0=\4\23\0035\4\24\0=\4\25\3=\3\26\0025\3\29\0005\4\27\0005\5\28\0=\5\v\4=\4\r\0035\4\30\0=\4\15\0035\4\31\0=\4 \3=\3!\0025\3$\0005\4\"\0005\5#\0=\5\v\4=\4\r\0035\4%\0=\4\15\3=\3&\0025\3'\0005\4(\0005\5)\0=\5\v\4=\4\r\0035\4*\0=\4\15\3=\3+\0025\3.\0005\4,\0005\5-\0=\5\v\4=\4\r\0035\4/\0=\4\15\3=\0030\0025\0031\0=\0032\0025\0033\0=\0034\0024\3\0\0=\0035\2B\0\2\1K\0\1\0\18actions_paths\23openai_edit_params\1\0\4\16temperature\3\0\nmodel\26code-davinci-edit-001\6n\3\1\ntop_p\3\1\18openai_params\1\0\a\6n\3\1\nmodel\18gpt-3.5-turbo\ntop_p\3\1\16temperature\3\0\15max_tokens\3¬\2\21presence_penalty\3\0\22frequency_penalty\3\0\20settings_window\1\0\1\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\1\0\0\1\0\1\btop\15 Settings \1\0\1\nstyle\frounded\16popup_input\1\0\1\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\1\0\2\btop\r Prompt \14top_align\vcenter\1\0\2\nstyle\frounded\14highlight\16FloatBorder\1\0\4\vsubmit\14<C-Enter>\22max_visible_lines\3\20\vprompt\n ï†’ \rsubmit_n\f<Enter>\18system_window\1\0\4\14linebreak\2\twrap\2\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\15foldcolumn\0062\1\0\0\1\0\1\btop\r SYSTEM \1\0\2\nstyle\frounded\14highlight\16FloatBorder\17popup_window\16buf_options\1\0\1\rfiletype\rmarkdown\1\0\4\14linebreak\2\twrap\2\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\15foldcolumn\0061\1\0\0\1\0\1\btop\14 ChatGPT \1\0\2\nstyle\frounded\14highlight\16FloatBorder\17popup_layout\nright\1\0\2\24width_settings_open\b50%\nwidth\b30%\vcenter\1\0\2\vheight\b80%\nwidth\b80%\1\0\1\fdefault\vcenter\tchat\nclose\1\0\15\14yank_last\n<C-y>\18draft_message\n<C-d>\18cycle_windows\n<Tab>\19rename_session\6r\20toggle_settings\n<C-o>\19select_session\f<Space>\19delete_session\6d\16cycle_modes\n<C-f>\24toggle_message_role\n<C-r>\16new_session\n<C-n>\16scroll_down\n<C-d>\28toggle_system_role_open\n<C-s>\14scroll_up\n<C-u>\20stop_generating\n<C-x>\19yank_last_code\n<C-k>\1\2\0\0\n<C-c>\20sessions_window\16win_options\1\0\1\17winhighlight*Normal:Normal,FloatBorder:FloatBorder\vborder\1\0\0\ttext\1\0\1\btop\15 Sessions \1\0\1\nstyle\frounded\1\0\5\16answer_sign\bï®§\20max_line_length\3x\18question_sign\bï€‡\17loading_text\29Loading, please wait ...\20welcome_message\16HELLO FREUD\27edit_with_instructions\fkeymaps\1\0\6\vaccept\n<C-y>\nclose\n<C-c>\24use_output_as_input\n<C-i>\18cycle_windows\n<Tab>\20toggle_settings\n<C-o>\16toggle_diff\n<C-d>\1\0\1\tdiff\1\1\0\4 predefined_chat_gpt_promptsQhttps://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv\24show_quickfixes_cmd\21Trouble quickfix\18yank_register\6+\16api_key_cmd.cat /home/stickuser/.config/openai/apikey\nsetup\fchatgpt\frequire\0", "config", "ChatGPT.nvim")
time([[Config for ChatGPT.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd nvim-treesitter ]]
time([[Sequenced loading]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType norg ++once lua require("packer.load")({'neorg'}, { ft = "norg" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'copilot.lua'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/sudacode/.local/share/nvim/site/pack/packer/opt/neorg/ftdetect/norg.lua]], true)
vim.cmd [[source /home/sudacode/.local/share/nvim/site/pack/packer/opt/neorg/ftdetect/norg.lua]]
time([[Sourcing ftdetect script at: /home/sudacode/.local/share/nvim/site/pack/packer/opt/neorg/ftdetect/norg.lua]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
