local fb_actions = require "telescope".extensions.file_browser.actions
require("telescope").setup {
  extensions = {
    file_browser = {
      -- theme = "ivy",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = {
        ["i"] = {
          -- your custom insert mode mappings
          ["<C-h>"] = fb_actions.goto_home_dir,
          ["<C-x>"] = function(prompt_bufnr)
          end
        },
        ["n"] = {
          -- your custom normal mode mappings
          f = false,
        },
      },
    },
  },
}
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension "file_browser"
