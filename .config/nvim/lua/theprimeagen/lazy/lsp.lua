return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "mason-org/mason.nvim",           version = "^1.0.0" },
        { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
        "stevearc/conform.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {},
        })

        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        capabilities.offsetEncoding = { "utf-16" }

        require("fidget").setup({})
        require("mason").setup()

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "gopls",
                "ts_ls",
                "pylsp",
                "ruff",
            },
            handlers = {
                -- default handler: register/configure the server and then enable it
                function(server_name)
                    vim.lsp.config(server_name, {
                        capabilities = capabilities,
                    })
                    vim.lsp.enable(server_name)
                end,

                -- zig (zls) custom config using vim.lsp.util.root_pattern
                zls = function()
                    vim.lsp.config("zls", {
                        root_dir = vim.lsp.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.lsp.enable("zls")

                    -- keep your zig format globals
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,

                -- lua_ls custom config
                ["lua_ls"] = function()
                    vim.lsp.config("lua_ls", {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                format = {
                                    enable = true,
                                    -- NOTE: values must be strings for some servers (kept from your original)
                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "2",
                                    },
                                },
                            },
                        },
                    })
                    vim.lsp.enable("lua_ls")
                end,

                -- pylsp custom config
                ["pylsp"] = function()
                    vim.lsp.config("pylsp", {
                        capabilities = capabilities,
                        settings = {
                            pylsp = {
                                plugins = {
                                    ruff = { enabled = true },
                                    black = { enabled = true },
                                    isort = { enabled = true },
                                    pyflakes = { enabled = false },
                                    flake8 = { enabled = false },
                                    pylint = { enabled = false },
                                    pycodestyle = { enabled = false },
                                    mccabe = { enabled = false },
                                    autopep8 = { enabled = false },
                                    yapf = { enabled = false },
                                },
                            },
                        },
                    })
                    vim.lsp.enable("pylsp")
                end,
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "copilot", group_index = 2 },
                { name = "nvim_lsp" },
                { name = "luasnip" }, -- For luasnip users.
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}
