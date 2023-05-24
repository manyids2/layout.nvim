local a = vim.api

local M = {}

function M.set_text(buf, text)
	a.nvim_buf_set_option(buf, "modifiable", true)
	a.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
	a.nvim_buf_set_option(buf, "modifiable", false)
end

return M
