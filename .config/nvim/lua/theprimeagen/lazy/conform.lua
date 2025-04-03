return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                -- Python
                python = { "black", "isort" },

                -- Go
                go = { "gofmt" },

                -- Add more formatters as needed
                -- lua = { "stylua" },
                -- javascript = { "prettier" },
                -- typescript = { "prettier" },
            },

            format_on_save = false,
        })

        -- Set up a key mapping to manually format
        vim.keymap.set("n", "<leader>f", function()
            conform.format({
                async = true,
                lsp_fallback = true,
            })
        end, { desc = "Format file" })
    end,
}
