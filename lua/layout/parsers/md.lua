local a = vim.api
local io = require("layout.io")
local Tree = require("layout.tree")

local M = {}

M.spacers = {
	"atx_h1_marker",
	"atx_h2_marker",
	"atx_h3_marker",
	"atx_h4_marker",
	"atx_h5_marker",
	"block_continuation",
	"list_marker_star",
	"list_marker_minus",
	"task_list_marker_unchecked",
	"task_list_marker_checked",
	"[x]",
}

M.contents = {
	"inline",
	"heading_content",
}

M.containers = {
	"document",
	"section",
	"atx_heading",
	"list",
	"list_item",
	"paragraph",
}

M.dtypes = {}
for _, dtype in pairs({ "containers", "contents", "spacers" }) do
	for _, elem in ipairs(M[dtype]) do
		M.dtypes[elem] = dtype
	end
end

M.get_data = {
	-- containers
	document = function(node, _, _)
		return { node = node, dtype = M.dtypes.document }
	end,
	section = function(node, _, _)
		return { node = node, dtype = M.dtypes.section }
	end,
	atx_heading = function(node, _, _)
		return { node = node, dtype = M.dtypes.section }
	end,
	list = function(node, _, _)
		return { node = node, dtype = M.dtypes.list }
	end,
	list_item = function(node, _, _)
		return { node = node, dtype = M.dtypes.list_item }
	end,
	paragraph = function(node, _, _)
		return { node = node, dtype = M.dtypes.paragraph }
	end,
	-- spacers
	atx_h1_marker = function(node, _, _)
		return { node = node, dtype = M.dtypes.atx_h1_marker }
	end,
	atx_h2_marker = function(node, _, _)
		return { node = node, dtype = M.dtypes.atx_h2_marker }
	end,
	atx_h3_marker = function(node, _, _)
		return { node = node, dtype = M.dtypes.atx_h3_marker }
	end,
	atx_h4_marker = function(node, _, _)
		return { node = node, dtype = M.dtypes.atx_h4_marker }
	end,
	atx_h5_marker = function(node, _, _)
		return { node = node, dtype = M.dtypes.atx_h5_marker }
	end,
	block_continuation = function(node, _, _)
		return { node = node, dtype = M.dtypes.block_continuation }
	end,
	list_marker_star = function(node, _, _)
		return { node = node, dtype = M.dtypes.list_marker_star }
	end,
	list_marker_minus = function(node, _, _)
		return { node = node, dtype = M.dtypes.list_marker_minus }
	end,
	task_list_marker_checked = function(node, _, _)
		return { node = node, dtype = M.dtypes.task_list_marker_checked }
	end,
	["[x]"] = function(node, _, _)
		return { node = node, dtype = M.dtypes["[x]"] }
	end,
	task_list_marker_unchecked = function(node, _, _)
		return { node = node, dtype = M.dtypes.task_list_marker_unchecked }
	end,
	-- contents
	inline = function(node, buf, size)
		local lines = M.get_node_lines(node, buf, size)
		return { node = node, dtype = M.dtypes.inline, lines = lines }
	end,
	heading_content = function(node, buf, size)
		local lines = M.get_node_lines(node, buf, size)
		return { node = node, dtype = M.dtypes.heading_content, lines = lines }
	end,
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

	-- trim
	local tlines = {}
	for _, line in ipairs(lines) do
		table.insert(tlines, vim.trim(line))
	end
	return tlines
end

function M.set_lines(tree, buf, size)
	local n = tree.tsnode
	if n then
		local data = M.get_data[n:type()](n, buf, size)
		if data.lines then
			local lines = data.lines
			local max = 0
			for _, line in ipairs(lines) do
				max = math.max(a.nvim_strwidth(line), max)
			end
			tree.th = vim.tbl_count(lines)
			tree.tw = max
			tree.lines = lines
			tree.dtype = data.dtype
		else
			tree.th = 0
			tree.tw = 0
			tree.lines = {}
			tree.dtype = data.dtype
		end
	end
	for _, child in ipairs(tree.c) do
		M.set_lines(child, buf, size)
	end
end

function M.print(tree)
	if tree.tsnode then
    print(tree.dtype, tree.tsnode:type())
		if tree.dtype == "contents" then
			P(tree.lines)
		end
		for _, child in ipairs(tree.c) do
			M.print(child)
		end
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
		local cnode = Tree:new(child, node, root)
		table.insert(node.c, M.setup_children(cnode, root))
	end
	node.nc = vim.tbl_count(node.c)
	return node
end

return M
