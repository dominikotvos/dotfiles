return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local parsers = {
            "vimdoc", "javascript", "typescript", "c", "lua", "rust",
            "jsdoc", "bash", "gdscript", "templ",
        }

        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        vim.treesitter.language.register("templ", "templ")

        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "help", "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                "bash", "gdscript", "templ",
            },
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
            end,
        })
    end
}
