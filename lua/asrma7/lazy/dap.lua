---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
	local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

	config = vim.deepcopy(config)
	---@cast args string[]
	config.args = function()
		local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
		if config.type and config.type == "java" then
			---@diagnostic disable-next-line: return-type-mismatch
			return new_args
		end
		return require("dap.utils").splitstr(new_args)
	end
	return config
end

return {
	{
		"mfussenegger/nvim-dap",
		recommended = true,
		desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
        -- stylua: ignore
        keys = {
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
            { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
            { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
            { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
        },

		init = function()
			vim.g.whichkeyAddSpec({ "<leader>d", group = "󰃤 Debugger" })
		end,
		config = function()
			-- ICONS & HIGHLIGHTS
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "󰇽", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapLogPoint", { text = "󰍩", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapLogRejected", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapStopped", {
				text = "󰳟",
				texthl = "DiagnosticHint",
				linehl = "DiagnosticVirtualTextHint",
				numhl = "DiagnosticVirtualTextHint",
			})

			-- LISTENERS
			local listeners = require("dap").listeners.after
			-- start nvim-dap-virtual-text
			listeners.attach.dapVirtText = function()
				local installed, dapVirtText = pcall(require, "nvim-dap-virtual-text")
				if installed then
					dapVirtText.enable()
				end
			end
			-- enable/disable diagnostics & line numbers
			listeners.attach.dapItself = function()
				vim.opt.number = true
				vim.diagnostic.enable(false)
			end
			listeners.disconnect.dapItself = function()
				vim.opt.number = false
				vim.diagnostic.enable(true)
			end

			-- LUALINE COMPONENTS
			-- breakpoint count
			vim.g.lualineAdd("sections", "lualine_y", {
				color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
				function()
					local breakpoints = require("dap.breakpoints").get()
					if #vim.iter(breakpoints):totable() == 0 then
						return ""
					end -- needs iter-wrap since sparse list
					local allBufs = 0
					for _, bp in pairs(breakpoints) do
						allBufs = allBufs + #bp
					end
					local thisBuf = #(breakpoints[vim.api.nvim_get_current_buf()] or {})
					local countStr = (thisBuf == allBufs) and thisBuf or thisBuf .. "/" .. allBufs
					local icon = vim.fn.sign_getdefined("DapBreakpoint")[1].text
					return icon .. countStr
				end,
			}, "before")

			-- status
			vim.g.lualineAdd("tabline", "lualine_z", function()
				local status = require("dap").status()
				if status == "" then
					return ""
				end
				return "󰃤 " .. status
			end)
			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end
		end,
	},

	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = "mason.nvim",
		cmd = { "DapInstall", "DapUninstall" },
		opts = {
			automatic_installation = true,
			handlers = {},
			ensure_installed = {
				"js-debug-adapter",
			},
		},
		config = function() end,
	},
}
