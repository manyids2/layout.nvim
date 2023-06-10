require("bootstrap")

vim.cmd([[colorscheme moonfly]])
vim.cmd([[set background=dark]])

-- setup the app
local app = require("layout"):new()
app:mount()
app:set_config()

local a = vim.api
local app_open = a.nvim_create_augroup("app_open", { clear = true })
a.nvim_create_autocmd({ "BufRead" }, {
	group = app_open,
	pattern = { "*.md", "*.markdown" },
	callback = function()
		app:open()
	end,
})
