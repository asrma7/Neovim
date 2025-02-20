return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.install").prefer_git = false
		if require("asrma7.utils").get_os() == "windows" then
			require("nvim-treesitter.install").compilers = { "zig" }
		end
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"vimdoc",
				"javascript",
				"typescript",
				"lua",
				"go",
				"bash",
				"css",
				"html",
				"sql",
				"markdown",
				"latex",
				"zig",
				"terraform",
				"yaml",
				"json",
				"python",
				"toml",
				"helm",
			},
			sync_install = false,
			ignore_install = {},
			modules = {},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
				disable = {},
			},
		})
	end,
}
