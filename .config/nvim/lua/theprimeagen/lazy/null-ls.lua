return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    opts = function()
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting
        local venv_path =
        'import sys; sys.path.append("/usr/lib/python3.12/site-packages"); import pylint_venv; pylint_venv.inithook(force_venv_activation=True, quiet=True)'
        null_ls.setup({
            sources = {
                null_ls.builtins.diagnostics.pylint.with({
                    extra_args = { "--init-hook", venv_path },
                    diagnostics_postprocess = function(diagnostic)
                        diagnostic.code = diagnostic.message_id
                    end,
                }),
                formatting.isort,
                formatting.black,
                require("none-ls.diagnostics.eslint"),
                require("none-ls.code_actions.eslint"),
                -- Prettier for all files with 4 spaces
                formatting.prettier.with({
                    extra_args = { "--tab-width", "4" },
                    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "yaml", "html", "css", "scss", "markdown", "tsx" }, -- Ensure TSX is included
                }),
                -- Set google_java_format to 4 spaces
                -- formatting.google_java_format.with({
                --     extra_args = { "--aosp" },
                -- }),
                formatting.gofmt
            },
        })
    end,
}

