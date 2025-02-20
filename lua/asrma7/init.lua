require("asrma7.set")
require("asrma7.remap")
require("asrma7.lazy_init")

local utils = require("asrma7.utils")

local augroup = vim.api.nvim_create_augroup
local asrma7Group = augroup("asrma7", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
	require("plenary.reload").reload_module(name)
end

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

autocmd({ "BufWritePre" }, {
	group = asrma7Group,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

vim.cmd("colorscheme base16-black-metal-gorgoroth")

utils.fix_telescope_parens_win()

utils.color_overrides.setup_colorscheme_overrides()
