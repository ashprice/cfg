vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","
vim.wo.number = true
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.tabstop = 2
vim.opt.expandtab = true

require("lazy").setup({
	spec = {
    { "echasnovski/mini.pairs",
    lazy = false,
    opts = {
      mappings = {
        ["'"] = { neigh_pattern = "[^%a\\|<|&]." },
        ["|"] = { action = "closeopen", pair="||", neigh_pattern = "[(][)]", register = { cr = false } },
      },
    },
    },
    { "loctvl842/monokai-pro.nvim",
    name = "monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        filter = "classic",
      })
      vim.cmd.colorscheme "monokai-pro"
    end,
    },
    { "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "main",
        dark_variant = "main",
        dim_inactive_windows = true,
        extend_background_behind_borders = true,
        enable = {
          terminal = true,
          legacy_highlights = true,
          migrations = true,
        },
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
      })
    end,
  },
	{ "nvim-telescope/telescope.nvim",
	dependencies = {
		{ "nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		keys = {
			{ "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
			{ "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
			{ "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
			{ "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Find help tags" },
		},
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
	{ "nvim-lua/plenary.nvim" },
}},
{ "lervag/vimtex",
init = function()
	vim.g.tex_flavor = 'lualatex'
	vim.g.vimtex_quickfix_open_on_warning = 0
	vim.g.vimtex_quickfix_autoclose_after_keystrokes = 2
	vim.g.vimtex_quickfix_mode = 0
	vim.g.vimtex_compiler_progname = 'nvr'
	vim.g.vimtex_view_general_viewer = 'zathura'
	vim.g.vimtex_compiler_latexmk = {
		continuous = 1,
		executable = '/usr/bin/latexmk',
		options = {
			'-shell-escape'
		}
	}
	vim.g.vimtex_complete_enabled=1
	end,
	ft = 'tex'
    },
    { "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
  },
},
defaults = {
	lazy = true,
},
})

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local util = require("luasnip.util.util")
local node_util = require("luasnip.nodes.util")

vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump(1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
vim.keymap.set('n', '<leader>L', '<Cmd>lua require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})<CR>')

-- feel free to change the keys to new ones, those are just my current mappings
vim.keymap.set("i", "<C-f>", function ()
    if ls.choice_active() then
        return ls.change_choice(1)
    else
        return _G.dynamic_node_external_update(1) -- feel free to update to any index i
    end
end, { noremap = true })
vim.keymap.set("s", "<C-f>", function ()
    if ls.choice_active() then
        return ls.change_choice(1)
    else
        return _G.dynamic_node_external_update(1)
    end
end, { noremap = true })
vim.keymap.set("i", "<C-d>", function ()
    if ls.choice_active() then
        return ls.change_choice(-1)
    else
        return _G.dynamic_node_external_update(2)
    end
end, { noremap = true })
vim.keymap.set("s", "<C-d>", function ()
    if ls.choice_active() then
        return ls.change_choice(-1)
    else
        return _G.dynamic_node_external_update(2)
    end
end, { noremap = true })

vim.keymap.set({"i", "s"}, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, {silent = true})
require("luasnip").config.set_config({
  enable_autosnippets = true,
  update_events = 'TextChanged,TextChangedI',
  store_selection_keys = "<Space>",
})
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})

local function find_dynamic_node(node)
	-- the dynamicNode-key is set on snippets generated by a dynamicNode only (its'
	-- actual use is to refer to the dynamicNode that generated the snippet).
	while not node.dynamicNode do
		node = node.parent
	end
	return node.dynamicNode
end

local external_update_id = 0
-- func_indx to update the dynamicNode with different functions.
function dynamic_node_external_update(func_indx)
	-- most of this function is about restoring the cursor to the correct
	-- position+mode, the important part are the few lines from
	-- `dynamic_node.snip:store()`.


	-- find current node and the innermost dynamicNode it is inside.
	local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
	local dynamic_node = find_dynamic_node(current_node)

	-- to identify current node in new snippet, if it is available.
	external_update_id = external_update_id + 1
	current_node.external_update_id = external_update_id
	local current_node_key = current_node.key

	-- store which mode we're in to restore later.
	local insert_pre_call = vim.fn.mode() == "i"
	-- is byte-indexed! Doesn't matter here, but important to be aware of.
	local cursor_pos_end_relative = util.pos_sub(
		util.get_cursor_0ind(),
		current_node.mark:get_endpoint(1)
	)

	-- leave current generated snippet.
	node_util.leave_nodes_between(dynamic_node.snip, current_node)

	-- call update-function.
	local func = dynamic_node.user_args[func_indx]
	if func then
		-- the same snippet passed to the dynamicNode-function. Any output from func
		-- should be stored in it under some unused key.
		func(dynamic_node.parent.snippet)
	end

	-- last_args is used to store the last args that were used to generate the
	-- snippet. If this function is called, these will most probably not have
	-- changed, so they are set to nil, which will force an update.
	dynamic_node.last_args = nil
	dynamic_node:update()

	-- everything below here isn't strictly necessary, but it's pretty nice to have.


    -- try to find the node we marked earlier, or a node with the same key.
    -- Both are getting equal priority here, it might make sense to give "exact
    -- same node" higher priority by doing two searches (but that would require
    -- two searches :( )
	local target_node = dynamic_node:find_node(function(test_node)
		return (test_node.external_update_id == external_update_id) or (current_node_key ~= nil and test_node.key == current_node_key)
	end)

	if target_node then
		-- the node that the cursor was in when changeChoice was called exists
		-- in the active choice! Enter it and all nodes between it and this choiceNode,
		-- then set the cursor.
		node_util.enter_nodes_between(dynamic_node, target_node)

		if insert_pre_call then
			-- restore cursor-position if the node, or a corresponding node,
			-- could be found.
			-- It is restored relative to the end of the node (as opposed to the
			-- beginning). This does not matter if the text in the node is
			-- unchanged, but if the length changed, we may move the cursor
			-- relative to its immediate neighboring characters.
			-- I assume that it is more likely that the text before the cursor
			-- got longer (since it is very likely that the cursor is just at
			-- the end of the node), and thus restoring relative to the
			-- beginning would shift the cursor back.
			-- 
			-- However, restoring to any fixed endpoint is likely to not be
			-- perfect, an interesting enhancement would be to compare the new
			-- and old text/[neighborhood of the cursor], and find its new position
			-- based on that.
			util.set_cursor_0ind(
				util.pos_add(
					target_node.mark:get_endpoint(1),
					cursor_pos_end_relative
				)
			)
		else
			node_util.select_node(target_node)
		end
		-- set the new current node correctly.
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = target_node
	else
		-- the marked node wasn't found, just jump into the new snippet noremally.
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
	end
end

