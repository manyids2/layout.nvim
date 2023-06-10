local io = require("layout.io")
local tt = require("layout.tree")

local M = {}

M.filter = {
	"section",
	"paragraph",
	"list",
	"list_item",
}

function M.parse(buf)
	local root = io.get_root(buf, "markdown")
	local tree = M.node_to_tree(root, tt.node(nil, nil))
	return tree
end

function M.node_to_tree(tsnode, parent)
	local tree = tt.node(tsnode, parent)
	for child in tsnode:iter_children() do
		if vim.tbl_contains(M.filter, child:type()) then
			table.insert(tree.c, M.node_to_tree(child, tree))
		end
	end
	tree.nc = vim.tbl_count(tree.c)
	return tree
end

return M
