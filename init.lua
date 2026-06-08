-- Change current working directory to the argument if it is a directory
vim.cmd([[if argc() == 1 && isdirectory(argv(0)) | cd `=argv(0)` | endif]])

require("asrma7")

local function source_matugen()
    local matugen_path = os.getenv("HOME") .. "/.config/nvim/lua/asrma7/matugen-nvim.lua"

    local file, err = io.open(matugen_path, "r")
    if err ~= nil then
        vim.cmd('colorscheme base16-catppuccin-mocha')

        vim.print(
            "A matugen style file was not found, but that's okay! The colorscheme will dynamically change if matugen runs!")
    else
        dofile(matugen_path)
        io.close(file)
    end
end

local function auxiliary_function()
    source_matugen()

    dofile(os.getenv("HOME") .. '/.config/nvim/lua/asrma7/lazy/lualine.lua')

    vim.api.nvim_set_hl(0, "Comment", { italic = true })
end

vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGUSR1",
    callback = auxiliary_function,
})

auxiliary_function()
