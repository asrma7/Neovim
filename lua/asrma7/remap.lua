vim.keymap.set("n", "<leader>pv", "<cmd>:Oil --float<CR>")

-- Open Lazy Plugin Manager
vim.keymap.set("n", "<leader>L", vim.cmd.Lazy)

-- Move selected line(s) down in visual mode and reselect the moved lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- Move selected line(s) up in visual mode and reselect the moved lines
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join the current line with the next one, keeping the cursor in place
vim.keymap.set("n", "J", "mzJ`z")
-- Scroll half a page down and center the cursor vertically
vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- Scroll half a page up and center the cursor vertically
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Jump to the next search result and center the cursor vertically
vim.keymap.set("n", "n", "nzzzv")
-- Jump to the previous search result and center the cursor vertically
vim.keymap.set("n", "N", "Nzzzv")

-- Paste in visual mode, but do not overwrite the unnamed register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank text into the system clipboard in normal and visual modes
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- Yank the current line into the system clipboard in normal mode
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete text without affecting the unnamed register in normal and visual modes
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Map <C-c> to <Esc> in insert mode (alternative way to exit insert mode)
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Disable the Q key in normal mode (often used to avoid accidental command recording)
vim.keymap.set("n", "Q", "<nop>")
-- Open a new tmux window running a sessionizer script with <C-f> in normal mode
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Move to the next quickfix item and center the cursor vertically with <C-;> in normal mode
vim.keymap.set("n", "<C-;>", "<cmd>cnext<CR>zz")
-- Move to the previous quickfix item and center the cursor vertically with <C-,> in normal mode
vim.keymap.set("n", "<C-,>", "<cmd>cprev<CR>zz")
-- Move to the next location list item and center the cursor vertically with <leader>k in normal mode
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- Move to the previous location list item and center the cursor vertically with <leader>j in normal mode
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Replace the word under the cursor in the entire file with confirmation, using <leader>s in normal mode
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Make the current file executable with <leader>x in normal mode
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Source the current Vim configuration file with <leader><leader> in normal mode
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

-- Open git status
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Key mappings for resolving merge conflicts using diffget
vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>") -- Theirs
vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>") -- Mine

-- Key mappings for toggling undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Zen mode key mappings
vim.keymap.set("n", "<leader>zz", function()
	require("zen-mode").setup({
		window = {
			width = 90,
			options = {},
		},
	})
	require("zen-mode").toggle()
	vim.wo.wrap = false
	vim.wo.number = true
	vim.wo.rnu = true
end)

vim.keymap.set("n", "<leader>zZ", function()
	require("zen-mode").setup({
		window = {
			width = 80,
			options = {},
		},
	})
	require("zen-mode").toggle()
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.rnu = false
	vim.opt.colorcolumn = "0"
end)

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Format the current buffer
vim.keymap.set({ "n", "i" }, "<C-f>", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { noremap = true, silent = true })

-- Custom telescope keybinding to find files and open them in a vertical split with <leader>sv in normal mode
vim.keymap.set("n", "<leader>sv", function()
	require("telescope.builtin").find_files({
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local action_state = require("telescope.actions.state")
				local actions = require("telescope.actions")
				local entry = action_state.get_selected_entry()
				if entry == nil then
					return
				end
				actions.close(prompt_bufnr)
				vim.cmd("vsplit " .. entry.path)
			end)
			return true
		end,
	})
end, { noremap = true, silent = true })

-- Custom telescope keybinding to find files and open them in a horizontal split with <leader>sz in normal mode
vim.keymap.set("n", "<leader>sz", function()
	require("telescope.builtin").find_files({
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local action_state = require("telescope.actions.state")
				local actions = require("telescope.actions")
				local entry = action_state.get_selected_entry()
				if entry == nil then
					return
				end
				actions.close(prompt_bufnr)
				vim.cmd("split " .. entry.path)
			end)
			return true
		end,
	})
end, { noremap = true, silent = true })

-- colorscheme picker
vim.keymap.set("n", "<C-n>", ":Telescope colorscheme<CR>")

-- Dismiss Noice notfications
vim.keymap.set("n", "<leader>nd", "<cmd>NoiceDismiss<CR>")
