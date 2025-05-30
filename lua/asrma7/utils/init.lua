local utils = {}

utils.color_overrides = require("asrma7.utils.color_overrides")

--- get the operating system name
--- "windows", "mac", "linux"
function utils.get_os()
	local uname = vim.loop.os_uname()
	local os_name = uname.sysname
	if os_name == "Windows_NT" then
		return "windows"
	elseif os_name == "Darwin" then
		return "mac"
	elseif uname.release:lower():find("microsoft") and true or false then
		return "wsl"
	else
		return "linux"
	end
end

-- fixes parenthesis issue with directories and telescope
function utils.fix_telescope_parens_win()
	if vim.fn.has("win32") then
		local ori_fnameescape = vim.fn.fnameescape
		---@diagnostic disable-next-line: duplicate-set-field
		vim.fn.fnameescape = function(...)
			local result = ori_fnameescape(...)
			return result:gsub("\\", "/")
		end
	end
end

-- capitalize first letter of each word
function utils.capitalize_words()
	vim.cmd([[
        s/\<\(\w\)\(\w*\)\>/\u\1\2/g
    ]])
end

return utils
