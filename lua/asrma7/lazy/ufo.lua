return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	event = "UIEnter",
	keys = {
		{ "<leader>if", vim.cmd.UfoInspect, desc = " Fold info" },
		{
			"zr",
			function()
				require("ufo").openFoldsExceptKinds({ "comment", "imports" })
			end,
			desc = "󱃄 Open regular folds",
		},
		{
			"z1",
			function()
				require("ufo").closeFoldsWith(1)
			end,
			desc = "󱃄 Close L1 folds",
		},
		{
			"z2",
			function()
				require("ufo").closeFoldsWith(2)
			end,
			desc = "󱃄 Close L2 folds",
		},
		{
			"z3",
			function()
				require("ufo").closeFoldsWith(3)
			end,
			desc = "󱃄 Close L3 folds",
		},
		{
			"z4",
			function()
				require("ufo").closeFoldsWith(4)
			end,
			desc = "󱃄 Close L4 folds",
		},
	},
	init = function()
		vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
	end,
	opts = {
		-- when opening the buffer, close these fold kinds
		cold_fold_kinds_for_ft = {
			default = { "comment", "imports" },
			json = { "array" },
			markdown = {},
			toml = {},
		},
		open_fold_hl_timeout = 800,
		provider_selector = function(_, ft, _)
			local lspWithOutFolding = { "markdown", "zsh", "bash", "css", "json", "yaml", "toml" }
			if vim.tbl_contains(lspWithOutFolding, ft) then
				return { "treesitter", "indent" }
			end
			return { "lsp", "indent" }
		end,
	},
}
