return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		default = {
			-- file and directory options
			dir_path = function()
				return vim.fn.expand("%:t:r")
			end, ---@type string | fun(): string
			extension = "png", ---@type string | fun(): string
			file_name = "%Y-%m-%d-%H-%M-%S", ---@type string | fun(): string
			use_absolute_path = false, ---@type boolean | fun(): boolean
			relative_to_current_file = false, ---@type boolean | fun(): boolean

			-- logging options
			verbose = true, ---@type boolean | fun(): boolean

			-- template options
			template = "$FILE_PATH", ---@type string | fun(context: table): string
			url_encode_path = false, ---@type boolean | fun(): boolean
			relative_template_path = true, ---@type boolean | fun(): boolean
			use_cursor_in_template = true, ---@type boolean | fun(): boolean
			insert_mode_after_paste = true, ---@type boolean | fun(): boolean
			insert_template_after_cursor = true, ---@type boolean | fun(): boolean

			-- prompt options
			prompt_for_file_name = true, ---@type boolean | fun(): boolean
			show_dir_path_in_prompt = false, ---@type boolean | fun(): boolean

			-- base64 options
			max_base64_size = 10, ---@type number | fun(): number
			embed_image_as_base64 = false, ---@type boolean | fun(): boolean

			-- image options
			process_cmd = "", ---@type string | fun(): string
			copy_images = false, ---@type boolean | fun(): boolean
			download_images = true, ---@type boolean | fun(): boolean

			-- drag and drop options
			drag_and_drop = {
				enabled = true, ---@type boolean | fun(): boolean
				insert_mode = false, ---@type boolean | fun(): boolean
			},
		},

		-- filetype specific options
		filetypes = {
			markdown = {
				url_encode_path = true, ---@type boolean | fun(): boolean
				template = "![$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
				download_images = false, ---@type boolean | fun(): boolean
			},

			vimwiki = {
				url_encode_path = true, ---@type boolean | fun(): boolean
				template = "![$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
				download_images = false, ---@type boolean | fun(): boolean
			},

			html = {
				template = '<img src="$FILE_PATH" alt="$CURSOR">', ---@type string | fun(context: table): string
			},

			tex = {
				relative_template_path = false, ---@type boolean | fun(): boolean
				template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
    ]], ---@type string | fun(context: table): string
			},

			typst = {
				template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
    ]], ---@type string | fun(context: table): string
			},

			rst = {
				template = [[
.. image:: $FILE_PATH
   :alt: $CURSOR
   :width: 80%
    ]], ---@type string | fun(context: table): string
			},

			asciidoc = {
				template = 'image::$FILE_PATH[width=80%, alt="$CURSOR"]', ---@type string | fun(context: table): string
			},

			org = {
				template = [=[
#+BEGIN_FIGURE
[[file:$FILE_PATH]]
#+CAPTION: $CURSOR
#+NAME: fig:$LABEL
#+END_FIGURE
    ]=], ---@type string | fun(context: table): string
			},
		},

		-- file, directory, and custom triggered options
		files = {}, ---@type table | fun(): table
		dirs = {}, ---@type table | fun(): table
		custom = {}, ---@type table | fun(): table
	},
}
