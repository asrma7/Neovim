return {
	{
		"leoluz/nvim-dap-go",
		config = function()
			local dap_go = require("dap-go")
			local custom_config = {
				{
					type = "go",
					name = "Debug Project",
					request = "launch",
					mode = "debug",
					program = "${workspaceFolder}/cmd/main.go",
					buildFlags = "",
					dlvToolPath = vim.fn.exepath("dlv"),
					args = {},
					output = "${workspaceFolder}/bin/debug",
					showLog = true,
				},
			}

			dap_go.setup()

			local dap = require("dap")

			table.insert(dap.configurations.go, 1, custom_config[1])
		end,
	},
}
