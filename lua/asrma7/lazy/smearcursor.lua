local os = require("asrma7.utils").get_os()
if os ~= "windows" and os ~= "wsl" then
	return {}
end
return {
	"sphamba/smear-cursor.nvim",
	opts = {},
}
