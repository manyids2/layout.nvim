local a = vim.api
local tsp = require("nvim-treesitter.parsers")

local M = {}

function M.set_text(buf, text)
	a.nvim_buf_set_option(buf, "modifiable", true)
	a.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
	a.nvim_buf_set_option(buf, "modifiable", false)
end

function M.get_root(buf, lang)
	local parser = tsp.get_parser(buf, lang)
	return parser:parse()[1]:root()
end

return M
