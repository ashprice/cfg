vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","

require("lazy").setup({
	spec = {
		{ "nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			config = function()
				require("telescope").load_extension("fzf")
			end,
			},
			{ "nvim-lua/plenary.nvim" },
		}}
	}
})
