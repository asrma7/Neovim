return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                PATH = "prepend",
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "bashls",
                    "lua_ls",
                    "cssls",
                    "gopls",
                    "html",
                    "emmet_language_server",
                    "tailwindcss",
                    "eslint",
                    "zls",
                    "marksman",
                    "sqlls",
                    "intelephense",
                    "jsonls",
                    "pylsp",
                    "ts_ls",
                    "vimls",
                    "yamlls",
                    "terraformls",
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(e)
                    local opts = { buffer = e.buf }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)

                    -- CursorHold highlight
                    local client = vim.lsp.get_client_by_id(e.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = e.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = e.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
            })

            -- Diagonistics Float Border
            vim.diagnostic.config({
                float = {
                    floatable = false,
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("sqlls", {
                capabilities = capabilities,
            })

            vim.lsp.config("intelephense", {
                capabilities = capabilities,
            })

            vim.lsp.config("texlab", {
                capabilities = capabilities,
            })

            vim.lsp.config("zls", {
                capabilities = capabilities,
            })

            vim.lsp.config("bashls", {
                capabilities = capabilities,
            })

            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }, -- Recognize 'vim' as a global variable
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true), -- Include neovim runtime
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            vim.lsp.config("jsonls", {
                capabilities = capabilities,
            })

            vim.lsp.config("yamlls", {
                capabilities = capabilities,
            })

            vim.lsp.config("gopls", {
                capabilities = capabilities,
            })

            vim.lsp.config("cssls", {
                capabilities = capabilities,
            })

            vim.lsp.config("html", {
                capabilities = capabilities,
                filetypes = {
                    "html",
                    "php",
                    "blade",
                    "css",
                    "javascriptreact",
                    "typescriptreact",
                    "javascript",
                    "typescript",
                    "jsx",
                    "tsx",
                },
            })

            vim.lsp.config("emmet_language_server", {
                capabilities = capabilities,
                filetypes = {
                    "html",
                    "php",
                    "blade",
                    "css",
                    "javascriptreact",
                    "typescriptreact",
                    "javascript",
                    "typescript",
                    "jsx",
                    "tsx",
                    "markdown",
                },
            })

            vim.lsp.config("tailwindcss", {
                capabilities = capabilities,
                filetypes = {
                    "html",
                    "php",
                    "blade",
                    "css",
                    "javascriptreact",
                    "typescriptreact",
                    "javascript",
                    "typescript",
                    "jsx",
                    "tsx",
                },
                root_dir = require("lspconfig").util.root_pattern(
                    "tailwind.config.js",
                    "tailwind.config.cjs",
                    "tailwind.config.mjs",
                    "tailwind.config.ts",
                    "postcss.config.js",
                    "postcss.config.cjs",
                    "postcss.config.mjs",
                    "postcss.config.ts",
                    "package.json",
                    "node_modules",
                    ".git"
                ),
            })

            local configs = require("lspconfig.configs")

            if not configs.ts_ls then
                configs.ts_ls = {
                    default_config = {
                        cmd = { "typescript-language-server", "--stdio" },
                        capabilities = capabilities,
                        filetypes = {
                            "javascript",
                            "javascriptreact",
                            "typescript",
                            "typescriptreact",
                            "html",
                        },
                        root_dir = require("lspconfig").util.root_pattern(
                            "package.json",
                            "tsconfig.json",
                            "jsconfig.json",
                            ".git"
                        ),
                    },
                }
            end
            vim.lsp.config("ts_ls", {})

            vim.lsp.config("eslint", {
                capabilities = capabilities,
            })

            local function get_python_path()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python3"
                else
                    local os_name = require("asrma7.utils").get_os()
                    if os_name == "windows" then
                        return "C:/python312"
                    else
                        return "/usr/bin/python3"
                    end
                end
            end

            vim.lsp.config("pylsp", {
                capabilities = capabilities,
                settings = {
                    python = {
                        pythonPath = get_python_path(),
                    },
                },
            })

            vim.lsp.config("marksman", {
                capabilities = capabilities,
            })

            vim.lsp.config("terraformls", {
                capabilities = capabilities,
            })
        end,
    },
}
