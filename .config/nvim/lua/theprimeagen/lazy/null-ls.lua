return {
    "nvimtools/none-ls.nvim",
    ft = { "python" },
    opts = function()
        local null_ls = require("null-ls")
        local venv_path =
        'import sys; sys.path.append("/usr/lib/python3.11/site-packages"); import pylint_venv; pylint_venv.inithook(force_venv_activation=True, quiet=True)'
        null_ls.setup({
            sources = {
                null_ls.builtins.diagnostics.pylint.with({
                    extra_args = { "--init-hook", venv_path },
                    diagnostics_postprocess = function(diagnostic)
                        diagnostic.code = diagnostic.message_id
                    end,
                }),
                null_ls.builtins.formatting.isort,
                null_ls.builtins.formatting.black,
            },
        })
    end,
}
