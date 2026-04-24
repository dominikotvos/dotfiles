return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                "jsdoc", "bash", "gdscript",
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
        })

        vim.treesitter.language.register("templ", "templ")
    end
}
