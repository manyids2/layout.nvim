local a = vim.api
local io = require("layout.io")
local Tree = require("layout.tree")

local md = {}

md.spacers = {
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
	":",
}

md.contents = {
	"inline",
	"heading_content",
}

md.containers = {
	"document",
	"section",
	"atx_heading",
	"list",
	"list_item",
	"paragraph",
}

md.dtypes = {}
for _, dtype in pairs({ "containers", "contents", "spacers" }) do
	for _, elem in ipairs(md[dtype]) do
		md.dtypes[elem] = dtype
	end
end

md.get_data = {}

-- containers
for _, name in ipairs(md.containers) do
	md.get_data[name] = function(_, _, _)
		return { dtype = md.dtypes[name] }
	end
end

-- spacers
for _, name in ipairs(md.spacers) do
	md.get_data[name] = function(_, _, _)
		return { dtype = md.dtypes[name] }
	end
end

-- contents
for _, name in ipairs(md.contents) do
	md.get_data[name] = function(tree, buf, size)
		local lines = tree:get_node_lines(buf, size)
		return { dtype = md.dtypes[name], lines = lines }
	end
end

-- override if necessary
md.get_data.inline = function(tree, buf, size)
	local lines = tree:get_node_lines(buf, size)
	return { dtype = md.dtypes.inline, lines = lines }
end

function md.parse(buf)
	local size = vim.tbl_count(a.nvim_buf_get_lines(buf, 0, -1, false))

	-- Initialize root
	local tsroot = io.get_root(buf, "markdown")
	local root = Tree:new(tsroot, nil, { size = size, dtype = "document" })

	-- Set up the tree
	root:setup_children(root, md.dtypes)

	-- Reset indices
	root:re_index(root, 0)

	-- Read lines from buffer
	root:set_lines(buf, size, md.get_data)
	return root
end

return md
