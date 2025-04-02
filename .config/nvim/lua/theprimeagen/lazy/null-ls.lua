return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
        "linux-cultist/venv-selector.nvim", -- Add dependency to ensure it loads first
    },
    opts = function()
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting

        -- Function to get current venv path from venv-selector
        local function get_python_path()
            -- Get the path from venv-selector if available
            local venv_path = require("venv-selector").get_active_venv()
            if venv_path then
                return venv_path .. "/bin/python"
            else
                -- Fallback to system Python
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end

        null_ls.setup({
            sources = {
                null_ls.builtins.diagnostics.pylint.with({
                    -- Use dynamic python path from active venv
                    command = function()
                        local venv_python = get_python_path()
                        local pylint_path = vim.fn.fnamemodify(venv_python, ":h") .. "/pylint"
                        return vim.fn.filereadable(pylint_path) == 1 and pylint_path or "pylint"
                    end,
                    diagnostics_postprocess = function(diagnostic)
                        diagnostic.code = diagnostic.message_id
                    end,
                }),
                formatting.isort.with({
                    command = function()
                        local venv_python = get_python_path()
                        local isort_path = vim.fn.fnamemodify(venv_python, ":h") .. "/isort"
                        return vim.fn.filereadable(isort_path) == 1 and isort_path or "isort"
                    end,
                }),
                formatting.black.with({
                    command = function()
                        local venv_python = get_python_path()
                        local black_path = vim.fn.fnamemodify(venv_python, ":h") .. "/black"
                        return vim.fn.filereadable(black_path) == 1 and black_path or "black"
                    end,
                }),
                formatting.gofmt
            },
        })
    end,
}
