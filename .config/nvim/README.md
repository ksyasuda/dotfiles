# Neovim Config

read_when: updating keymaps, startup order, or plugin layout

## Load Order

1. `init.lua`
2. `core.lazy` (bootstraps lazy.nvim, loads options)
3. colorscheme
4. `core.keymaps` (core editing, LSP, commands, and which-key groups)
5. `core.autocmds`
6. `core.highlights`
7. Hyprland LSP helper

## Where To Edit

- Options: `lua/core/options.lua`
- Autocmds: `lua/core/autocmds.lua`
- Highlights: `lua/core/highlights.lua`
- Keymaps entrypoint: `lua/core/keymaps/init.lua`
- Keymaps by domain:
  - `lua/core/keymaps/editing.lua`
  - `lua/core/keymaps/lsp.lua`
  - `lua/core/keymaps/commands.lua`
  - `lua/core/keymaps/groups.lua`
- Plugin setup and plugin-owned mappings: `lua/plugins/*.lua`

## Structure Notes

- Keep plugin specs in `lua/plugins/`.
- Keep core logic in `lua/core/`.
- Keep reusable helpers in `lua/utils/`.
- Put plugin mappings in the plugin spec's `keys` table so Lazy can load them on demand.
- Use `which-key` only to label mapping groups.

## Tool Ownership

- Formatting: Conform, with explicit formatters and no LSP fallback.
- Linting: nvim-lint on save. Codespell and pydoclint are linters.
- Completion: nvim-cmp with LuaSnip. None-ls is not part of completion.
- File browsing: Snacks Explorer.
- Notifications: Snacks Notifier. Fidget owns LSP progress, and Noice owns command/message UI.

## Checks

```sh
stylua --check .
luacheck .
nvim --headless -i NONE -u ./init.lua '+qa'
```
