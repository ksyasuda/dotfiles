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
local package_path_str = "/home/sudacode/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/sudacode/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/sudacode/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/sudacode/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/sudacode/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
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
    config = { "\27LJ\2\n�\6\0\0\6\0\26\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0006\3\4\0=\3\5\0025\3\6\0005\4\a\0=\4\b\3=\3\t\0025\3\n\0005\4\v\0005\5\f\0=\5\r\4=\4\14\3=\3\15\0025\3\16\0005\4\17\0005\5\18\0=\5\r\4=\4\14\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\fkeymaps\1\0\4\14scroll_up\n<C-u>\nclose\n<C-c>\16scroll_down\n<C-d>\14yank_last\n<C-y>\18openai_params\1\0\a\nmodel\21text-davinci-003\ntop_p\3\1\16temperature\3\0\15max_tokens\3�\2\21presence_penalty\3\0\22frequency_penalty\3\0\6n\3\1\15chat_input\16win_options\1\0\1\17winhighlight\18Normal:Normal\1\0\2\14top_align\vcenter\btop\r Prompt \1\0\2\nstyle\frounded\14highlight\16FloatBorder\1\0\1\vprompt\n  \16chat_window\vborder\ttext\1\0\1\btop\14 ChatGPT \1\0\2\nstyle\frounded\14highlight\16FloatBorder\1\0\1\rfiletype\fchatgpt\16chat_layout\tsize\1\0\2\vheight\b80%\nwidth\b80%\1\0\2\rrelative\veditor\rposition\b50%\20welcome_message\20WELCOME_MESSAGE\1\0\5\18question_sign\b\17loading_text\floading\18yank_register\6+\20max_line_length\3x\16answer_sign\bﮧ\nsetup\fchatgpt\frequire\0" },
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
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
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
    config = { "\27LJ\2\n]\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\vmethod\26getCompletionsCycling\nsetup\16copilot_cmp\frequire\0" },
    load_after = {
      ["copilot.lua"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/opt/copilot-cmp",
    url = "https://github.com/zbirenbaum/copilot-cmp"
  },
  ["copilot.lua"] = {
    after = { "copilot-cmp" },
    config = { "\27LJ\2\n�\3\0\0\6\0\20\0\0306\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\0025\3\b\0005\4\t\0=\4\5\3=\3\n\0026\3\v\0009\3\f\0039\3\r\3'\5\14\0B\3\2\2'\4\15\0&\3\4\3=\3\16\0024\3\0\0=\3\17\2B\0\2\0016\0\0\0'\2\18\0B\0\2\0029\0\19\0B\0\1\1K\0\1\0\24toggle_auto_trigger\23copilot.suggestion\26server_opts_overrides\24plugin_manager_path\22/site/pack/packer\tdata\fstdpath\afn\bvim\15suggestion\1\0\4\tprev\n<M-[>\tnext\n<M-]>\fdismiss\n<C-]>\vaccept\n<Tab>\1\0\3\rdebounce\3K\fenabled\2\17auto_trigger\2\npanel\1\0\1\25copilot_node_command\tnode\vkeymap\1\0\5\14jump_prev\a[[\frefresh\agr\topen\v<C-CR>\14jump_next\a]]\vaccept\t<CR>\1\0\2\17auto_refresh\1\fenabled\2\nsetup\fcopilot\frequire-\1\0\4\0\3\0\0066\0\0\0009\0\1\0003\2\2\0)\3d\0B\0\3\1K\0\1\0\0\rdefer_fn\bvim\0" },
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
  ["fidget.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/fidget.nvim",
    url = "https://github.com/j-hui/fidget.nvim"
  },
  fzf = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
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
    url = "https://github.com/ksyasuda/lsp_lines.nvim"
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
  ["nvim-lsp-installer"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-lsp-installer",
    url = "https://github.com/williamboman/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-lspfuzzy"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/nvim-lspfuzzy",
    url = "https://github.com/ojroques/nvim-lspfuzzy"
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
  ["telescope-file-browser.nvim"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
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
  ["vim-css-color"] = {
    loaded = true,
    path = "/home/sudacode/.local/share/nvim/site/pack/packer/start/vim-css-color",
    url = "https://github.com/ap/vim-css-color"
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
try_loadstring("\27LJ\2\n�\6\0\0\2\0\21\0M6\0\0\0009\0\1\0+\1\1\0=\1\2\0006\0\0\0009\0\1\0+\1\1\0=\1\3\0006\0\0\0009\0\1\0+\1\2\0=\1\4\0006\0\0\0009\0\1\0+\1\2\0=\1\5\0006\0\0\0009\0\1\0+\1\2\0=\1\6\0006\0\0\0009\0\1\0+\1\1\0=\1\a\0006\0\0\0009\0\1\0+\1\1\0=\1\b\0006\0\0\0009\0\1\0)\1\20\0=\1\t\0006\0\0\0009\0\1\0+\1\1\0=\1\n\0006\0\0\0009\0\1\0+\1\1\0=\1\v\0006\0\0\0009\0\1\0+\1\2\0=\1\f\0006\0\0\0009\0\1\0+\1\2\0=\1\r\0006\0\0\0009\0\1\0+\1\2\0=\1\14\0006\0\0\0009\0\1\0+\1\2\0=\1\15\0006\0\0\0009\0\1\0+\1\1\0=\1\16\0006\0\0\0009\0\1\0+\1\2\0=\1\17\0006\0\0\0009\0\1\0+\1\2\0=\1\18\0006\0\0\0009\0\1\0+\1\1\0=\1\19\0006\0\0\0009\0\1\0+\1\2\0=\1\20\0K\0\1\0\28doom_one_plugin_lspsaga#doom_one_plugin_vim_illuminate%doom_one_plugin_indent_blankline\29doom_one_plugin_whichkey\29doom_one_plugin_startify\30doom_one_plugin_dashboard\30doom_one_plugin_nvim_tree\27doom_one_plugin_neogit\30doom_one_plugin_telescope\27doom_one_plugin_barbar\26doom_one_plugin_neorg#doom_one_pumblend_transparency\29doom_one_pumblend_enable$doom_one_transparent_background$doom_one_diagnostics_text_color\31doom_one_enable_treesitter\29doom_one_italic_comments\29doom_one_terminal_colors\29doom_one_cursor_coloring\6g\bvim\0", "setup", "doom-one.nvim")
time([[Setup for doom-one.nvim]], false)
time([[packadd for doom-one.nvim]], true)
vim.cmd [[packadd doom-one.nvim]]
time([[packadd for doom-one.nvim]], false)
-- Config for: ChatGPT.nvim
time([[Config for ChatGPT.nvim]], true)
try_loadstring("\27LJ\2\n�\6\0\0\6\0\26\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0006\3\4\0=\3\5\0025\3\6\0005\4\a\0=\4\b\3=\3\t\0025\3\n\0005\4\v\0005\5\f\0=\5\r\4=\4\14\3=\3\15\0025\3\16\0005\4\17\0005\5\18\0=\5\r\4=\4\14\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\fkeymaps\1\0\4\14scroll_up\n<C-u>\nclose\n<C-c>\16scroll_down\n<C-d>\14yank_last\n<C-y>\18openai_params\1\0\a\nmodel\21text-davinci-003\ntop_p\3\1\16temperature\3\0\15max_tokens\3�\2\21presence_penalty\3\0\22frequency_penalty\3\0\6n\3\1\15chat_input\16win_options\1\0\1\17winhighlight\18Normal:Normal\1\0\2\14top_align\vcenter\btop\r Prompt \1\0\2\nstyle\frounded\14highlight\16FloatBorder\1\0\1\vprompt\n  \16chat_window\vborder\ttext\1\0\1\btop\14 ChatGPT \1\0\2\nstyle\frounded\14highlight\16FloatBorder\1\0\1\rfiletype\fchatgpt\16chat_layout\tsize\1\0\2\vheight\b80%\nwidth\b80%\1\0\2\rrelative\veditor\rposition\b50%\20welcome_message\20WELCOME_MESSAGE\1\0\5\18question_sign\b\17loading_text\floading\18yank_register\6+\20max_line_length\3x\16answer_sign\bﮧ\nsetup\fchatgpt\frequire\0", "config", "ChatGPT.nvim")
time([[Config for ChatGPT.nvim]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'copilot.lua'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
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
