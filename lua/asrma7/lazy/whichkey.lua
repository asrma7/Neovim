vim.g.whichkeyAddSpec = function(spec)
    if not spec.mode then spec.mode = { "n", "x" } end
    -- Deferred to ensure spec is loaded after whichkey itself
    vim.defer_fn(function() require("which-key").add(spec) end, 1500)
end

return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
