local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
local adapters = { "pwa-node", "pwa-chrome", "node-terminal", "pwa-extensionHost" }
local vscode_adapters = { "node", "chrome" }

return {
	"microsoft/vscode-js-debug",
	build = "npm ci --loglevel=error && npm run compile -- dapDebugServer",
	config = function()
		local dap = require("dap")
		local dap_vscode = require("dap.ext.vscode")
		local json = require("plenary.json")
		---@diagnostic disable-next-line: duplicate-set-field
		dap_vscode.json_decode = function(str)
			return vim.json.decode(json.json_strip_comments(str, {}))
		end
		dap_vscode.type_to_filetypes["node"] = js_filetypes
		for _, adapter in ipairs(adapters) do
			if not dap.adapters[adapter] then
				dap.adapters[adapter] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							vim.fn.resolve(
								vim.fn.stdpath("data") .. "/lazy/vscode-js-debug/dist/src/dapDebugServer.js"
							),
							"${port}",
						},
					},
				}
			end
		end

		for _, adapter in ipairs(vscode_adapters) do
			if not dap.adapters[adapter] then
				dap.adapters[adapter] = function(cb, config)
					if config.type == adapter then
						config.type = "pwa-" .. adapter
					end
					local nativeAdapter = dap.adapters["pwa-" .. adapter]
					if type(nativeAdapter) == "function" then
						nativeAdapter(cb, config)
					else
						cb(nativeAdapter)
					end
				end
			end
		end

		for _, language in ipairs(js_filetypes) do
			dap.configurations[language] = {
				-- Next.js configuration for npm run dev
				{
					name = "Debug NPM project",
					type = "pwa-node",
					request = "launch",
					cwd = "${workspaceFolder}",
					runtimeExecutable = "npm",
					runtimeArgs = { "run", "dev" },
					skipFiles = { "<node_internals>/**" },
					sourceMaps = true,
					console = "integratedTerminal",
					resolveSourceMapLocations = {
						"${workspaceFolder}/**",
						"!**/node_modules/**",
					},
				},
				{
					type = "pwa-chrome",
					request = "launch",
					port = 9229,
					name = "Launch & Debug Chrome",
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
					name = "----- ↑ launch.json configs (if available) ↑ -----",
					type = "",
					request = "launch",
				},
			}
		end
	end,
}
