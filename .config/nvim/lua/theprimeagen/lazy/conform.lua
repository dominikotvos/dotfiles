return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                python = { "black", "isort" },
                go = { "gofmt" },
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                cpp = { "clang_format" },
                h = { "clang_format" },
                c = { "clang_format" },
                gdscript = { "gdformat" },
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
