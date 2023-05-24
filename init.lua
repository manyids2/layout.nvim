require("bootstrap")

vim.cmd([[colorscheme moonfly]])
vim.cmd([[set background=dark]])

-- setup the app
require("layout").setup()

local a = vim.api
local app_open = a.nvim_create_augroup("app_open", { clear = true })
a.nvim_create_autocmd({ "BufRead" }, {
  group = app_open,
  callback = function()
    require("layout").setup()
  end,
})
