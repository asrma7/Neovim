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

			-- javascript debugging
			local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
			local dap = require("dap")

			local dap_vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			---@diagnostic disable-next-line: duplicate-set-field
			dap_vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str, {}))
			end

			dap_vscode.type_to_filetypes["node"] = js_filetypes

			if not dap.adapters["pwa-node"] then
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							vim.fn.resolve(
								vim.fn.stdpath("data")
									.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
							),
							" ${port}",
						},
					},
				}
			end

			if not dap.adapters["node"] then
				dap.adapters["node"] = function(cb, config)
					if config.type == "node" then
						config.type = "pwa-node"
					end
					local nativeAdapter = dap.adapters["pwa-node"]
					if type(nativeAdapter) == "function" then
						nativeAdapter(cb, config)
					else
						cb(nativeAdapter)
					end
				end
			end

			for _, language in ipairs(js_filetypes) do
				dap.configurations[language] = {
					{
						name = "Launch file",
						type = "pwa-node",
						request = "launch",
						program = "${file}",
						cwd = "${workspaceFolder}",
						args = { "${file}" },
						sourceMaps = true,
						sourceMapPathOverrides = {
							["./*"] = "${workspaceFolder}/src/*",
						},
					},
					{
						name = "Attach",
						type = "pwa-node",
						request = "attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
					},
					{
						type = "pwa-msedge",
						request = "launch",
						name = "Launch & Debug Edge",
						url = function()
							local co = coroutine.running()
							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = "${workspaceFolder}",
						skipFiles = { "<node_internals>/**/*.js" },
						protocol = "inspector",
						sourceMaps = true,
						userDataDir = false,
					},
					{
						name = "Launch & Debug Chrome",
						type = "pwa-chrome",
						request = "launch",
						url = function()
							local co = coroutine.running()
							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = vim.fn.getcwd(),
						protocol = "inspector",
						sourceMaps = true,
						userDataDir = false,
						resolveSourceMapLocations = {
							"${workspaceFolder}/**",
							"!**/node_modules/**",
						},
						rootPath = "${workspaceFolder}",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
						sourceMapPathOverrides = {
							["./*"] = "${workspaceFolder}/src/*",
						},
					},
					{
						name = "----- ↑ launch.json configs (if available) ↑ -----",
						type = "",
						request = "launch",
					},
				}
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
