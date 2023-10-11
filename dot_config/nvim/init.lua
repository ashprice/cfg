vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","
vim.wo.number = true
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

require("lazy").setup({
	spec = {
		{ "nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			keys = {
				{ "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
				{ "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
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
			vim.g.vimtex_quickfix_open_on_warning=0
			vim.g.vimtex_quickfix_autoclose_after_keystrokes=2
			vim.g.vimtex_quickfix_mode=0
			vim.g.vimtex_compiler_progname='nvr'
			vim.g.vimtex_view_general_viewer='zathura'
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
	},
	defaults = {
		lazy = true,
		},
})

