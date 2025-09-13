return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("obsidian").setup({
            legacy_commands = false,
            workspaces = {
                {
                    name = "personal",
                    path = "~/obsidian-vault",
                },
            },

            notes_subdir = "000-RoughNotes",

            daily_notes = {
                folder = "001-Diary",
                default_tags = { "diary" },
                template = "Diary",
            },

            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },

            -- mappings = {
            --     ["gf"] = {
            --         action = function()
            --             return require("obsidian").util.gf_passthrough()
            --         end,
            --         opts = { noremap = false, expr = true, buffer = true },
            --     },
            --     ["<leader>ch"] = {
            --         action = function()
            --             return require("obsidian").util.toggle_checkbox()
            --         end,
            --         opts = { buffer = true },
            --     },
            --     ["<cr>"] = {
            --         action = function()
            --             return require("obsidian").util.smart_action()
            --         end,
            --         opts = { buffer = true, expr = true },
            --     },
            --     ["<leader>on"] = {
            --         action = function()
            --             vim.cmd("ObsidianTemplate Notes")
            --         end,
            --     },
            --     ["<leader>os"] = {
            --         action = function()
            --             vim.cmd("ObsidianQuickSwitch")
            --         end,
            --     },
            --     -- format title in the note
            --     ["<leader>of"] = {
            --         action = function()
            --             vim.cmd(":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g | lua require('asrma7.utils').capitalize_words()")
            --         end,
            --     },
            -- },

            new_notes_location = "notes_subdir",

            ---@param title string|?
            ---@return string
            note_id_func = function(title)
                local suffix = ""
                if title ~= nil then
                    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                else
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                return tostring(os.date("%Y-%m-%d")) .. "_" .. suffix
            end,

            ---@param spec { id: string, dir: obsidian.Path, title: string|? }
            ---@return string|obsidian.Path
            note_path_func = function(spec)
                local path = spec.dir / tostring(spec.id)
                return path:with_suffix(".md")
            end,

            preferred_link_style = "wiki",

            disable_frontmatter = true,

            templates = {
                folder = "999-Templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
                substitutions = {},
            },

            ---@param url string
            follow_url_func = function(url)
                vim.ui.open(url)
            end,

            picker = {
                name = "telescope.nvim",
                note_mappings = {
                    new = "<C-x>",
                    insert_link = "<C-l>",
                },
                tag_mappings = {
                    tag_note = "<C-x>",
                    insert_tag = "<C-l>",
                },
            },

            sort_by = "modified",
            sort_reversed = true,

            search_max_lines = 1000,

            callbacks = {
                -- Runs at the end of `require("obsidian").setup()`.
                ---@param client obsidian.Client
                post_setup = function(client) end,

                -- Runs anytime you enter the buffer for a note.
                ---@param client obsidian.Client
                ---@param note obsidian.Note
                enter_note = function(client, note) end,

                -- Runs anytime you leave the buffer for a note.
                ---@param client obsidian.Client
                ---@param note obsidian.Note
                leave_note = function(client, note) end,

                -- Runs right before writing the buffer for a note.
                ---@param client obsidian.Client
                ---@param note obsidian.Note
                pre_write_note = function(client, note) end,

                -- Runs anytime the workspace is set/changed.
                ---@param client obsidian.Client
                ---@param workspace obsidian.Workspace
                post_set_workspace = function(client, workspace) end,
            },

            ui = {
                enable = true,
                update_debounce = 200,
                max_file_length = 5000,
                checkbox = { " ", "x", ">", "~", "!" },
                bullets = { char = "•", hl_group = "ObsidianBullet" },
                external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                reference_text = { hl_group = "ObsidianRefText" },
                highlight_text = { hl_group = "ObsidianHighlightText" },
                tags = { hl_group = "ObsidianTag" },
                block_ids = { hl_group = "ObsidianBlockID" },
                hl_groups = {
                    ObsidianTodo = { bold = true, fg = "#f78c6c" },
                    ObsidianDone = { bold = true, fg = "#89ddff" },
                    ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                    ObsidianTilde = { bold = true, fg = "#ff5370" },
                    ObsidianImportant = { bold = true, fg = "#d73128" },
                    ObsidianBullet = { bold = true, fg = "#89ddff" },
                    ObsidianRefText = { underline = true, fg = "#c792ea" },
                    ObsidianExtLinkIcon = { fg = "#c792ea" },
                    ObsidianTag = { italic = true, fg = "#89ddff" },
                    ObsidianBlockID = { italic = true, fg = "#89ddff" },
                    ObsidianHighlightText = { bg = "#75662e" },
                },
            },

            attachments = {
                img_folder = "998-Assets",

                ---@return string
                img_name_func = function()
                    return string.format("%s-", os.time())
                end,

                ---@param client obsidian.Client
                ---@param path obsidian.Path
                ---@return string
                img_text_func = function(client, path)
                    path = client:vault_relative_path(path) or path
                    return string.format("![%s](%s)", path.name, path)
                end,
            },
        })
    end,
}
