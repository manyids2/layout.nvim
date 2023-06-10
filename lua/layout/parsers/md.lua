local a = vim.api
local io = require("layout.io")
local Tree = require("layout.tree")

local M = {}

M.filter = {
	"section",
	"paragraph",
	"list",
	"list_item",
}

function M.get_node_lines(tsnode, buf, size)
	local sr, sc, er, ec = tsnode:range()
	if er >= size then
		er = er - 1
	end
	if sr == er then
		sc = math.min(sc, ec)
	end
	local lines = a.nvim_buf_get_text(buf, sr, sc, er, ec, {})
	return lines
end

function M.set_lines(tree, buf, size)
	if tree.tsnode then
		local lines = M.get_node_lines(tree.tsnode, buf, size)
		local max = 0
		for _, line in ipairs(lines) do
			max = math.max(a.nvim_strwidth(line), max)
		end
		tree.th = vim.tbl_count(lines)
		tree.tw = max
		tree.lines = lines
		-- tree.lines = lines
		P(lines)
	end
	for _, child in ipairs(tree.c) do
		M.set_lines(child, buf, size)
	end
end

function M.parse(buf)
	local size = vim.tbl_count(a.nvim_buf_get_lines(buf, 0, -1, false))

	local tsroot = io.get_root(buf, "markdown")
	local root = Tree:new(tsroot, nil, { size = size })
	M.setup_children(root, root)

	return root
end

function M.setup_children(node, root)
	for child in node.tsnode:iter_children() do
		if vim.tbl_contains(M.filter, child:type()) then
			local cnode = Tree:new(child, node, root)
			table.insert(node.c, M.setup_children(cnode, root))
		end
	end
	node.nc = vim.tbl_count(node.c)
	return node
end

return M
