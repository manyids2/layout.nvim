local a = vim.api
local tt = require("layout.tree")

local M = {}

M.queries = {
	kv_pair = [[(
  document
    ((block_mapping_pair) @_name
    (#offset! @_name 0 0 0 0 ))
  )]],
}

function M.parse(buf)
	-- actually use treesitter
	-- local root = io.get_root(buf, "yaml"):type()
	-- local matches = ts.get_matches(M.queries.kv_pair, root, buf, "yaml")
	-- P(matches)
	-- HACK: assume flat dict, so just cut lines
	local lines = a.nvim_buf_get_lines(buf, 0, -1, false)
	local root = tt.new("", {}, nil)
	for linenr, line in ipairs(lines) do
		local parts = vim.split(line, ":")
		local node = tt.new(line, { key = vim.trim(parts[1]), value = vim.trim(parts[2]), linenr = linenr }, root)
		table.insert(root.c, node)
	end
	return root
end

function M.config_from_tree(tree)
	-- HACK: assumes flat dict
	local data = {}
	for _, child in ipairs(tree.c) do
		data[child.data.key] = child.data.value
	end
	return data
end

return M
