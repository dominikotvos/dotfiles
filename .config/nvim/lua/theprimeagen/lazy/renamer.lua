return {
    {
        "smjonas/inc-rename.nvim",
        config = function()
            require("inc_rename").setup {
                input_buffer_type = "dressing",
                vim.keymap.set("n", "<leader>rn", ":IncRename ")
            }
        end,
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
    }
}

