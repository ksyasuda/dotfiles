local home = os.getenv('HOME')
local db = require('dashboard')
-- macos
-- db.preview_command = 'cat | lolcat -F 0.3'
-- linux
-- db.preview_command = 'ueberzug'
-- db.preview_file_path = home .. '/.config/nvim/static/neovim.cat'
-- db.preview_file_height = 11
-- db.preview_file_width = 70
vim.cmd('source $HOME/.config/nvim/static/nvim-dashboard.vim')
db.custom_center = {
    {
        icon = '  ',
        desc = 'Recently latest session                  ',
        shortcut = 'SPC s l',
        action = 'SessionLoad'
    }, {
    icon = '  ',
    desc = 'Recently opened files                   ',
    action = 'Telescope oldfiles',
    shortcut = 'SPC f h'
}, {
    desc = 'Find  File                              ',
    icon = '  ',
    action = 'Telescope find_files find_command=rg,--hidden,--files',
    shortcut = 'SPC f f'
}, {
    icon = '  ',
    desc = 'File Browser                            ',
    action = 'Telescope file_browser',
    shortcut = 'SPC f b'
}, {
    icon = '  ',
    desc = 'Find  word                              ',
    action = 'Telescope live_grep',
    shortcut = 'SPC f w'
}, {
    icon = '  ',
    desc = 'Open Personal dotfiles                  ',
    action = ':e ~/.config/nvim/init.vim',
    shortcut = 'SPC f d'
}
}
require('dashboard').setup {
    theme = 'doom',                  --  theme is doom and hyper default is hyper
    disable_move = false,            --  default is false disable move keymap for hyper
    shortcut_type = 'number',        --  shorcut type 'letter' or 'number'
    change_to_vcs_root = false,      -- default is false,for open file in hyper mru. it will change to the root of vcs
    config = {
        header = { "NVIM DASHBOARD" }, -- your header
        center = {
            {
                icon = ' ',
                icon_hl = 'Title',
                desc = 'Open Recent',
                desc_hl = 'String',
                key = '1',
                keymap = 'SPC f r',
                key_hl = 'Number',
                action = 'lua print(1)'
            }, {
            icon = '  ',
            icon_hl = 'Title',
            desc = 'Find File',
            desc_hl = 'String',
            key = '2',
            key_hl = 'Number',
            keymap = 'SPC f f',
            action = 'lua print(2)'
        }

            -- {
            -- icon = ' ',
            -- desc = 'Find Dotfiles',
            -- key = 'f',
            -- keymap = 'SPC f d',
            -- action = 'lua print(3)'
            -- }
        },
        footer = {} -- your footer
    },
    hide = {
        statusline = true, -- hide statusline default is true
        tabline = true,    -- hide the tabline
        winbar = true      -- hide winbar
    }
    -- preview = {
    --     command = "bat",     -- preview command
    --     file_path   -- preview file path
    --     file_height -- preview file height
    --     file_width  -- preview file width
    -- },
}
