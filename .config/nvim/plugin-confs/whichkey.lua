local wk = require("which-key")

wk.setup {
    plugins = {
        marks = true,        -- shows a list of your marks on ' and `
        registers = true,    -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
            enabled = true,  -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20 -- how many suggestions should be shown in the list?
        },
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = true,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = true,      -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true,      -- default bindings on <c-w>
            nav = true,          -- misc bindings to work with windows
            z = true,            -- bindings for folds, spelling and others prefixed with z
            g = true             -- bindings for prefixed with g
        }
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+" -- symbol prepended to a group
    },
    popup_mappings = {
        scroll_down = '<c-d>', -- binding to scroll down inside the popup
        scroll_up = '<c-u>'    -- binding to scroll up inside the popup
    },
    window = {
        border = "none",        -- none, single, double, shadow
        position = "bottom",    -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
        winblend = 0
    },
    layout = {
        height = { min = 4, max = 25 },                                         -- min and max height of the columns
        width = { min = 20, max = 50 },                                         -- min and max width of the columns
        spacing = 3,                                                            -- spacing between columns
        align = "left"                                                          -- align columns left, center or right
    },
    ignore_missing = false,                                                     -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true,                                                           -- show help message on the command line when the popup is visible
    show_keys = true,                                                           -- show the key strokes for your commands
    triggers = "auto",                                                          -- automatically setup triggers
    -- triggers = {"<leader>"}, -- or specify a list manually
    triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for key maps that start with a native binding
        -- most people should not need to change this
        i = { "j", "k" },
        v = { "j", "k" }
    },
    disable = { buftypes = {}, filetypes = { "TelescopePrompt" } }
}

wk.register({
    a = { name = "AnyJump", b = "Back", l = "Last Result" },
    b = {
        name = "Buffers",
        b = "Show Buffers",
        d = "Delete Buffer",
        n = "Next Buffer",
        p = "Previous Buffer"
    },
    c = {
        name = "Code",
        a = "Code Action",
        d = "Diagnostics",
        D = {
            name = "Diagnostic List",
            n = "Next Diagnostic",
            p = "Previous Diagnostic"
        },
        p = "Copilot Panel",
        l = "Set Loclist"
    },
    C = {
        name = "ChatGPT",
        i = "Edit with Instructions",
        d = "Docstring",
        t = "Add Tests",
        o = "Optimize Code",
        s = "Summarize",
        f = "Fix Bugs",
        e = "Explain Code"
    },
    d = {
        name = "Debug",
        b = "Toggle Breakpoint",
        c = "Continue",
        i = "Step Into",
        o = "Step Over",
        O = "Step Out",
        r = "REPL Open",
        l = "Run Last",
        h = "Hover",
        p = "Preview",
        f = "Frames",
        s = "Scopes",
        u = { name = "Dap UI", t = "Toggle", o = "Open", c = "Close" },
        P = {
            name = "Dap-python",
            m = "Test Method",
            c = "Test Class",
            s = "Debug Selection"
        }
    },
    f = {
        name = "Find File",
        b = "File Browser",
        c = "File Color",
        f = "Find in Current Directory",
        g = "Live Grep",
        r = "File Recent"
    },
    g = {
        name = "Git",
        b = "Blame",
        c = "Commit",
        f = "Files",
        g = "Lazygit",
        P = "Close goto-preview window",
        R = "Telescope References",
        p = {
            "Peek",
            c = "Close Preview",
            d = "Preview Definition",
            i = "Preview Implementation"
        }
    },
    h = {
        name = "Help",
        c = "Commands",
        d = {
            name = "Dap",
            c = "Commands",
            C = "Configurations",
            b = "Breakpoints",
            v = "Variables",
            f = "Frames"
        },
        v = "Vim Options",
        k = "Keymaps",
        s = "Spell Suggest"
    },
    i = { name = "Insert", s = { name = "Snippet", p = "Python File" } },
    j = "Any Jump",
    K = "Show Docs",
    l = {
        name = "LSP",
        d = "Definitions",
        D = "Diagnostics",
        a = "Code Actions",
        c = { name = "Calls", i = "Incoming", o = "Outgoing" },
        h = "Signature Help",
        i = "Implementations",
        r = "References",
        R = "Rename",
        s = "Document Symbols",
        t = "Type Definitions",
        w = "Workspace Symbols"
    },
    n = "NvimTree",
    o = {
        name = "Open",
        b = "File Browser",
        B = "Btop",
        c = "ChatGPT",
        C = "Nvim Config",
        d = "Lazydocker",
        f = "Floating Terminal",
        h = "Horizontal Terminal",
        p = "Ipython",
        P = "Ipython (fullscreen)",
        r = "Ranger",
        t = "Vertical Terminal"
    },
    s = {
        name = "Search",
        c = "Clear Highlights",
        C = "Commands",
        f = "Files",
        g = "Glyph",
        h = "Command History",
        m = "Man Pages"
    },
    t = {
        name = "Toggle",
        c = "Colorscheme",
        d = "DBUI",
        f = "Floating Terminal",
        p = "Ipython",
        P = "Ipython (fullscreen)",
        t = "Split Terminal"
    },
    T = {
        name = "Telescope",
        c = "Color Names",
        g = "Glyph",
        n = "Notifications",
        t = "Telescope"
    },
    w = {
        name = "Workspace",
        a = "Add Folder",
        l = "List Folders",
        r = "Remove Folder"
    },
    x = "Set Executable Bit",
    y = "System Yank"
}, { prefix = "<leader>" })
