local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.hyprlang = {
	install_info = {
		url = "~/github/tree-sitter-hyprlang", -- local path or git repo
		files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
		-- optional entries:
		branch = "main", -- default branch in case of git repo if different from master
		generate_requires_npm = false, -- if stand-alone parser without npm dependencies
		requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
	},
	filetype = "conf", -- if filetype does not match the parser name
}
vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})
