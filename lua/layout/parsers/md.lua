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
	"task_list_marker_checked",
	"task_list_marker_unchecked",
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

M.filter = {
	"section",
}

function M.get_data_section(section, buf, size)
	local marker = section:child():child()
	local content = marker:next_sibling()
	local lines = M.get_node_lines(content, buf, size)
	return { marker = marker:type(), lines = lines }
end

function M.get_data_paragraph(paragraph, buf, size)
	local inline = paragraph:child()
	local lines = M.get_node_lines(inline, buf, size)
	return { lines = lines }
end

function M.get_data_list(list, buf, size)
	return { list = list, lines = { "" } }
end

function M.get_data_list_item(list_item, buf, size)
	local inline = list_item:child()
	local lines = M.get_node_lines(list_item, buf, size)
	return { lines = lines }
end

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
	local data = { lines = { " " } }
	if n then
		if n:type() == "section" then
			data = M.get_data_section(n, buf, size)
		elseif n:type() == "paragraph" then
			data = M.get_data_paragraph(n, buf, size)
		elseif n:type() == "list" then
			data = M.get_data_list(n, buf, size)
		elseif n:type() == "list_item" then
			data = M.get_data_list_item(n, buf, size)
		elseif n:type() == "document" then
			data = { lines = { "" } }
		end
		local lines = data.lines
		local max = 0
		for _, line in ipairs(lines) do
			max = math.max(a.nvim_strwidth(line), max)
		end
		tree.th = vim.tbl_count(lines)
		tree.tw = max
		tree.lines = lines
	end
	for _, child in ipairs(tree.c) do
		M.set_lines(child, buf, size)
	end
end

function M.print(tree)
	if tree.tsnode then
		print(tree.tsnode:type())
	end
	P(tree.lines)
	for _, child in ipairs(tree.c) do
		M.print(child)
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
