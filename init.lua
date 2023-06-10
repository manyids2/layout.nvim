require("bootstrap")

vim.cmd([[colorscheme rosebones]])
vim.cmd([[set background=dark]])

-- setup the app
local app = require("layout.app"):new()
app:mount()

local a = vim.api
local app_open = a.nvim_create_augroup("app_open", { clear = true })
a.nvim_create_autocmd({ "BufRead" }, {
	group = app_open,
	pattern = { "*.md", "*.markdown" },
	callback = function()
		local filename = a.nvim_exec2("echo expand('%')", { output = true }).output
		app:open(filename)
	end,
})
